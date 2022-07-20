# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KEYWORDS="~amd64"
RESTRICT="mirror"

USE_DOTNET="net45"
IUSE="+net45 developer debug nupkg gac doc"

SLOT="3"

inherit mono-env gac nupkg versionator

NAME="nunit-console"
HOMEPAGE="https://github.com/nunit/${NAME}"

EGIT_BRANCH="mono4"
EGIT_COMMIT="ce1cd856258dac867da4044eed5864de225c148d"
SRC_URI="https://github.com/ArsenShnurkov/nunit-console/archive/3.7.0.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${NAME}-${PV}"

DESCRIPTION="NUnit Console runner and test engine"
LICENSE="MIT" # https://github.com/nunit/nunit/blob/master/LICENSE.txt
#USE_DOTNET="net20 net40 net45"

CDEPEND=">=dev-lang/mono-5.0.1.1
	>=dev-dotnet/nunit-framework-3.7.0
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
	!dev-util/nunit
"

METAFILETOBUILD="${S}/${FILE_TO_BUILD}"

NUGET_PACKAGE_VERSION="$(get_version_component_range 1-3)"

src_compile() {
	exbuild_strong "src/NUnitEngine/nunit.engine.api/nunit.engine.api.csproj"
	exbuild_strong "src/NUnitEngine/nunit.engine/nunit.engine.csproj"
	exbuild "src/NUnitEngine/nunit-agent/nunit-agent.csproj"
	exbuild "src/NUnitConsole/nunit3-console/nunit3-console.csproj"
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	SLOTTEDDIR="/usr/share/nunit-${SLOT}/"
	insinto "${SLOTTEDDIR}"
	doins bin/${DIR}/*.{config,dll,exe}
	# install: cannot stat 'bin/Release/*.mdb': No such file or directory
	if use developer; then
		doins bin/${DIR}/*.mdb
	fi
	egacinstall "bin/${DIR}/nunit.engine.dll"
	egacinstall "bin/${DIR}/nunit.engine.api.dll"
	einstall_pc_file "${PN}" "${PV}" "nunit.engine" "nunit.engine.api"

	make_wrapper nunit "mono ${SLOTTEDDIR}/nunit3-console.exe"

	if use doc; then
		doins LICENSE.txt NOTICES.txt CHANGES.txt
	fi
}
