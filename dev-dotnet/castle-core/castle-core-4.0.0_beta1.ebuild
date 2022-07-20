# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +gac developer debug doc"

inherit gac dotnet

SRC_URI="https://github.com/castleproject/Core/archive/v4.0.0-beta001.tar.gz -> ${PN}-${PV}.tar.gz"
RESTRICT="mirror"
S="${WORKDIR}/Core-4.0.0-beta001"

HOMEPAGE="https://www.castleproject.org/"
DESCRIPTION="including Castle DynamicProxy, Logging Services and DictionaryAdapter "
LICENSE="Apache-2.0" # https://github.com/castleproject/Core/blob/master/LICENSE
KEYWORDS="~amd64"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_prepare() {
	eapply "${FILESDIR}/add-version-property-handling.patch"
	eapply "${FILESDIR}/remove-warnings-as-errors-${PV}.patch"
	eapply_user
}

src_compile() {
	if use debug; then
		CARGS=/p:Configuration=NET45-Debug
	else
		CARGS=/p:Configuration=NET45-Release
	fi

	if use developer; then
		SARGS=/p:DebugSymbols=True
	else
		SARGS=/p:DebugSymbols=False
	fi

	exbuild_raw /v:detailed /tv:4.0 /p:TargetFrameworkVersion=v4.5 ${CARGS} ${SARGS} /p:VersionNumber=4.0.0.0 "/p:RootPath=${S}" "Castle.Core.sln"
}

src_install() {
	if use debug; then
		CONFIGURATION=NET45-Debug
	else
		CONFIGURATION=NET45-Release
	fi
	egacinstall "src/Castle.Core/bin/${CONFIGURATION}/Castle.Core.dll"
	einstall_pc_file "${PN}" "${PV}" "Castle.Core"
}
