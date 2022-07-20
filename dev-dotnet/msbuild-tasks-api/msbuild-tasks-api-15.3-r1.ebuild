# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"
KEYWORDS="~amd64"
SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +gac developer debug doc"

inherit gac dotnet xbuild

#https://github.com/mono/linux-packaging-msbuild/commit/0d8cee3f87b92cff425306d9c588fc6433fb6bf0
GITHUB_ACCOUNT="mono"
GITHUB_PROJECTNAME="linux-packaging-msbuild"
EGIT_COMMIT="e08c20fd277b9de1e3a97c5bd9a5dcf95fcff926"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> msbuild-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

HOMEPAGE="https://github.com/mono/linux-packaging-msbuild"
DESCRIPTION="msbuild libraries for writing Task-derived classes"
LICENSE="MIT" # https://github.com/mono/linux-packaging-msbuild/blob/main/LICENSE

COMMON_DEPEND=">=dev-lang/mono-5.2.0.196
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

UT_PROJ=Microsoft.Build.Utilities
FW_PROJ=Microsoft.Build.Framework
UT_DIR=src/Utilities
FW_DIR=src/Framework

src_prepare() {
	mkdir -p "${S}/packages/msbuild/" || die
	cp "${FILESDIR}/MSFT.snk" "${S}/packages/msbuild/" || die
	cp "${FILESDIR}/mono.snk" "${S}/packages/msbuild/" || die
	eapply "${FILESDIR}/dir.props.diff"
	eapply "${FILESDIR}/dir.targets.diff"
	eapply "${FILESDIR}/src-dir.targets.diff"
	sed -i 's/CurrentAssemblyVersion = "15.1.0.0"/CurrentAssemblyVersion = "15.3.0.0"/g' "${S}/src/Shared/Constants.cs" || die
	eapply "${FILESDIR}/ToolLocationHelper.cs.patch"
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

	VER=15.3.0.0
	#KEY="${S}/packages/msbuild/MSFT.snk"
	KEY2="${S}/packages/msbuild/mono.snk"
	KEY="${KEY2}"

	exbuild_raw /v:detailed /p:MonoBuild=true /p:TargetFrameworkVersion=v4.6 "/p:Configuration=${CONFIGURATION}" /p:${SARGS} "/p:VersionNumber=${VER}" "/p:RootPath=${S}" "/p:SignAssembly=true" "/p:AssemblyOriginatorKeyFile=${KEY}" "${S}/${FW_DIR}/${FW_PROJ}.csproj"
	sn -R "${S}/bin/${CONFIGURATION}/x86/Unix/Output/${FW_PROJ}.dll" "${KEY2}" || die
	exbuild_raw /v:detailed /p:MonoBuild=true /p:TargetFrameworkVersion=v4.6 "/p:Configuration=${CONFIGURATION}" /p:${SARGS} "/p:VersionNumber=${VER}" "/p:RootPath=${S}" "/p:SignAssembly=true" "/p:AssemblyOriginatorKeyFile=${KEY}" "${S}/${UT_DIR}/${UT_PROJ}.csproj"
	sn -R "${S}/bin/${CONFIGURATION}/x86/Unix/Output/${UT_PROJ}.Core.dll" "${KEY2}" || die
}

src_install() {
	if use debug; then
		CONFIGURATION=Debug
	else
		CONFIGURATION=Release
	fi

	egacinstall "${S}/bin/${CONFIGURATION}/x86/Unix/Output/${FW_PROJ}.dll"
	egacinstall "${S}/bin/${CONFIGURATION}/x86/Unix/Output/${UT_PROJ}.Core.dll"
	# einstall_pc_file "${PN}" "${PV}" "${FW_PROJ}" "${UT_PROJ}"
}
