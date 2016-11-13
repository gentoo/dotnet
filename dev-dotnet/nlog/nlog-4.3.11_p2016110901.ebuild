# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"
USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +gac +nupkg developer debug doc"

SLOT="0"

inherit mono-env gac nupkg

NAME="NLog"
HOMEPAGE="https://github.com/ArsenShnurkov/${NAME}"

EGIT_BRANCH="MONO_4_0"
EGIT_COMMIT="c3eb07ff89523154dc2385c7db0ba9437bff3362"
SRC_URI="${HOMEPAGE}/archive/${EGIT_BRANCH}/${EGIT_COMMIT}.tar.gz -> ${PF}.tar.gz"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION=" NLog - Advanced .NET and Silverlight Logging http://nlog-project.org"
LICENSE="BSD"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

S="${WORKDIR}/${NAME}-${EGIT_BRANCH}"
FILE_TO_BUILD=./src/NLog.mono4.sln
METAFILETOBUILD="${S}/${FILE_TO_BUILD}"

COMMIT_DATE_INDEX="$(get_version_component_count ${PV} )"
COMMIT_DATEANDSEQ="$(get_version_component_range $COMMIT_DATE_INDEX ${PV} )"
NUSPEC_VERSION=$(get_version_component_range 1-3)"${COMMIT_DATEANDSEQ//p/.}"

src_prepare() {
	chmod -R +rw "${S}" || die

	# enuget_restore is commented out, because it give errors:
	#    Unable to find version '1.6.4375' of package 'StatLight'.
	#    Unable to find version '1.9.2' of package 'xunit.runners'.
	#enuget_restore "${METAFILETOBUILD}"

	epatch "${FILESDIR}/NLog.mono4.sln.patch"
	epatch "${FILESDIR}/NoStdLib-NoConfig.patch"
	epatch "${FILESDIR}/NLog.nuspec.patch"

	eapply_user
}

# cd /var/lib/layman/dotnet
# ebuild ./dev-dotnet/NLog/NLog-4.1.3_pre-r201510280.ebuild compile
src_compile() {
	exbuild "${METAFILETOBUILD}"

	einfo Package name ${PN}

	enuspec -Prop BuildVersion=${NUSPEC_VERSION} ./src/NuGet/NLog/NLog.nuspec
	# Successfully created package '/var/tmp/portage/dev-dotnet/NLog-4.1.3_pre-r201510280/work/NLog.4.1.3.0.nupkg'.
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	if use gac; then
		egacinstall "${S}/build/bin/${DIR}/Mono 4.x/NLog.dll"
		egacinstall "${S}/build/bin/${DIR}/Mono 4.x/NLog.Extended.dll"
	fi

	if use doc; then
#		doins xml comments file
		doins LICENSE.txt
	fi

	enupkg "${WORKDIR}/NLog.${NUSPEC_VERSION}.nupkg"
}
