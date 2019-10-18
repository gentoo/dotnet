# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

RESTRICT="mirror"
KEYWORDS="~amd64"
SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +gac developer debug doc"

inherit dotnet xbuild gac

GITHUB_ACCOUNT="dotnet"
GITHUB_PROJECTNAME="corefx"
EGIT_COMMIT="247068fbd97c534dc13b3b9d037f67b03dbe57a5"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${GITHUB_PROJECTNAME}-${GITHUB_ACCOUNT}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

HOMEPAGE="https://github.com/dotnet/corefx/tree/master/src/System.Collections.Immutable"
DESCRIPTION="part of CoreFX"
LICENSE="MIT" # https://github.com/dotnet/corefx/blob/master/LICENSE.TXT

COMMON_DEPEND=">=dev-lang/mono-5.2.0.196
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	dev-dotnet/buildtools
"

PROJ1=System.Collections.Immutable
PROJ1_DIR=src/${PROJ1}/src

src_prepare() {
	cp "${FILESDIR}/mono-${PROJ1}.csproj" "${S}/${PROJ1_DIR}/" || die
	eapply_user
}

src_compile() {
	if use debug; then
		CONFIGURATION=Debug
	else
		CONFIGURATION=Release
	fi

	if use developer; then
		SARGS=DebugSymbols=True
	else
		SARGS=DebugSymbols=False
	fi

	VER=2.0.0.0
	KEY="${FILESDIR}/mono.snk"

	exbuild_raw /v:detailed /p:TargetFrameworkVersion=v4.6 "/p:Configuration=${CONFIGURATION}" /p:${SARGS} "/p:VersionNumber=${VER}" "/p:RootPath=${S}" "/p:SignAssembly=true" "/p:AssemblyOriginatorKeyFile=${KEY}" "${S}/${PROJ1_DIR}/mono-${PROJ1}.csproj"
	sn -R "${PROJ1_DIR}/bin/${CONFIGURATION}/${PROJ1}.dll" "${KEY}" || die
}

src_install() {
	if use debug; then
		CONFIGURATION=Debug
	else
		CONFIGURATION=Release
	fi

	egacinstall "${PROJ1_DIR}/bin/${CONFIGURATION}/${PROJ1}.dll"
	einstall_pc_file "${PN}" "${PV}" "${PROJ1}"
}
