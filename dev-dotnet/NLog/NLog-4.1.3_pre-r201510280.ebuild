# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit mono-env dotnet nupkg gac

NAME="NLog"
HOMEPAGE="https://github.com/ArsenShnurkov/${NAME}"

EGIT_BRANCH="MONO_4_0"
EGIT_COMMIT="c3eb07ff89523154dc2385c7db0ba9437bff3362"
SRC_URI="${HOMEPAGE}/archive/${EGIT_BRANCH}/${EGIT_COMMIT}.zip -> ${PF}.zip"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="0"

DESCRIPTION=" NLog - Advanced .NET and Silverlight Logging http://nlog-project.org"
LICENSE="BSD" # https://github.com/ArsenShnurkov/NLog/blob/master/LICENSE.txt
KEYWORDS="~amd64 ~ppc ~x86"
#USE_DOTNET="net20 net40 net45"
USE_DOTNET="net45"

# USE Flag 'net45' not in IUSE for dev-dotnet/NLog-4.1.3_pre-r201510280
IUSE="net45 +gac +nupkg developer debug doc"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

S="${WORKDIR}/${NAME}-${EGIT_BRANCH}"
FILE_TO_BUILD=./src/NLog.mono4.sln
METAFILETOBUILD="${S}/${FILE_TO_BUILD}"

NUGET_VERSION=${PV//_pre/.0}

src_prepare() {
	chmod -R +rw "${S}" || die

	# enuget_restore is commented out, because it give errors:
	#    Unable to find version '1.6.4375' of package 'StatLight'.
	#    Unable to find version '1.9.2' of package 'xunit.runners'.
	#enuget_restore "${METAFILETOBUILD}"

	epatch "${FILESDIR}/NLog.mono4.sln.patch"
	epatch "${FILESDIR}/NoStdLib-NoConfig.patch"
	epatch "${FILESDIR}/NLog.nuspec.patch"
}

# cd /var/lib/layman/dotnet
# ebuild ./dev-dotnet/NLog/NLog-4.1.3_pre-r201510280.ebuild compile
src_compile() {
	exbuild "${METAFILETOBUILD}"

	einfo Package name ${PN}

	enuspec -Prop BuildVersion=${NUGET_VERSION} ./src/NuGet/NLog/NLog.nuspec
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

	enupkg "${WORKDIR}/NLog.${NUGET_VERSION}.nupkg"
}
