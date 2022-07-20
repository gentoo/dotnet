# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"
KEYWORDS="~amd64"
SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +gac developer debug doc"

inherit gac dotnet

GITHUB_ACCOUNT="nhibernate"
GITHUB_PROJECTNAME="iesi.collections"
EGIT_COMMIT="3e183dd3316baedac508d0171b67c3dee05f6da0"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

HOMEPAGE="https://www.codeproject.com/Articles/3190/Add-Support-for-quot-Set-quot-Collections-to-NET"
DESCRIPTION='C#, LinkedHashSet<T>, SynchronizedSet<T>, ReadOnlySet<T>'
LICENSE="TODO" # https://github.com/nhibernate/iesi.collections/blob/master/LICENSE.txt

COMMON_DEPEND=">=dev-lang/mono-5.2.0.196
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	>=dev-dotnet/msbuildtasks-1.5.0.240
"

PROJECT_FILE_DIR="${S}/src/Iesi.Collections"
PROJECT_NAME="Iesi.Collections"
ASSEMBLY_VERSION="${PV}"

src_prepare() {
	cp "${FILESDIR}/${PROJECT_NAME}.csproj" "${PROJECT_FILE_DIR}/" || die
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

	exbuild_raw /v:detailed /p:TargetFrameworkVersion=v4.5 "/p:Configuration=${CONFIGURATION}" /p:${SARGS} /p:VersionNumber="${ASSEMBLY_VERSION}" "/p:RootPath=${S}" "${PROJECT_FILE_DIR}/${PROJECT_NAME}.csproj"
}

src_install() {
	if use debug; then
		CONFIGURATION=Debug
	else
		CONFIGURATION=Release
	fi

	DLLNAME="${PROJECT_FILE_DIR}/bin/${CONFIGURATION}/${PROJECT_NAME}.dll"
	sn -R "${DLLNAME}" "${S}/src/NHibernate.snk" || die
	egacinstall ${DLLNAME}
	einstall_pc_file "${PN}" "${PV}" "${PROJECT_NAME}"
}
