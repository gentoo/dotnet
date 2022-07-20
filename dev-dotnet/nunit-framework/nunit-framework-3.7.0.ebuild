# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KEYWORDS="~amd64"
RESTRICT="mirror"

#USE_DOTNET="net20 net40 net45"
USE_DOTNET="net45"
IUSE="+net45 developer debug nupkg gac doc"

inherit mono-env gac nupkg versionator

NAME="nunit"
HOMEPAGE="https://github.com/nunit/${NAME}"

EGIT_COMMIT="aa669b7e142954541d25fbb1a4ef660ca5f97f1a"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="370"

DESCRIPTION="NUnit test suite for mono applications"
LICENSE="MIT" # https://github.com/nunit/nunit/blob/master/LICENSE.txt

CDEPEND=">=dev-lang/mono-5.0.1.1
	net45? (
		developer? (
			debug?  ( dev-dotnet/cecil[net45,gac,developer,debug] )
			!debug? ( dev-dotnet/cecil[net45,gac,developer] )
		)
		!developer? (
			debug?  ( dev-dotnet/cecil[net45,gac,debug] )
			!debug? ( dev-dotnet/cecil[net45,gac] )
		)
	)
"

DEPEND="${CDEPEND}
	net45? (
		developer? (
			debug? ( dev-util/nant[net45,nupkg,developer,debug] )
			!debug? ( dev-util/nant[net45,nupkg,developer] )
		)
		!developer? (
			debug? ( dev-util/nant[net45,nupkg,debug] )
			!debug? ( dev-util/nant[net45,nupkg] )
		)
	)
"

RDEPEND="${CDEPEND}
"

FILE_TO_BUILD=src/NUnitFramework/framework/nunit.framework-4.5.csproj
METAFILETOBUILD="${S}/${FILE_TO_BUILD}"

NUGET_PACKAGE_VERSION="$(get_version_component_range 1-3)"

src_compile() {
	exbuild_strong "${METAFILETOBUILD}"
}

src_install() {
	if use debug; then
		DIR=Debug
	else
		DIR=Release
	fi
	egacinstall "bin/${DIR}/net-4.5/nunit.framework.dll"
	einstall_pc_file "${PN}" "${PV}" "nunit.framework"
}
