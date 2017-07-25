# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
RESTRICT="mirror"
KEYWORDS="~amd64 ~ppc ~x86"
SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +gac developer debug doc"

inherit gac dotnet

GITHUB_ACCOUNT="Antlr"
GITHUB_PROJECTNAME="antlr3"
EGIT_COMMIT="5c2a916a10139cdb5c7c8851ee592ed9c3b3d4ff"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

HOMEPAGE="http://www.antlr.org/"
DESCRIPTION="C# runtime for ANTLR (ANother Tool for Language Recognition)"
LICENSE="BSD" # https://github.com/antlr/antlr3/blob/master/runtime/CSharp2/LICENSE.TXT

COMMON_DEPEND=">=dev-lang/mono-5.2.0.196
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

PROJECT_FILE_DIR="${S}/runtime/CSharp2/Sources/Antlr3.Runtime"
PROJECT_NAME="Antlr3.Runtime"

src_prepare() {
	sed -i "s/3.1.3.\*/3.2.0.0/g" "${PROJECT_FILE_DIR}/AssemblyInfo.cs" || die
	cp "${FILESDIR}/${PROJECT_NAME}.csproj" "${PROJECT_FILE_DIR}/" || die
	cp "${FILESDIR}/IAstRuleReturnScope\`1.cs" "${PROJECT_FILE_DIR}/Antlr.Runtime/" || die
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

	exbuild_raw /v:detailed /p:TargetFrameworkVersion=v4.5 "/p:Configuration=${CONFIGURATION}" /p:${SARGS} /p:VersionNumber=3.2 "/p:RootPath=${S}" "${PROJECT_FILE_DIR}/${PROJECT_NAME}.csproj"
}

src_install() {
	if use debug; then
		CONFIGURATION=Debug
	else
		CONFIGURATION=Release
	fi

	DLLNAME="${PROJECT_FILE_DIR}/bin/${CONFIGURATION}/${PROJECT_NAME}.dll"
	sn -R "${DLLNAME}" "${PROJECT_FILE_DIR}/../Antlr3_KeyPair.snk" || die
	egacinstall ${DLLNAME}
	einstall_pc_file "${PN}" "${PV}" "${PROJECT_NAME}"
}
