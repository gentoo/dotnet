# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

RESTRICT="mirror"
KEYWORDS="~amd64"

SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +gac developer debug doc +symlink"

inherit dotnet xbuild gac mono-pkg-config

GITHUB_ACCOUNT="dotnet"
GITHUB_PROJECTNAME="buildtools"
EGIT_COMMIT="a177c85d78799e6c2407ce88e857546e490d83c2"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${GITHUB_PROJECTNAME}-${GITHUB_ACCOUNT}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

HOMEPAGE="https://github.com/dotnet/buildtools"
DESCRIPTION="Build tools that are necessary for building the .NET Core projects"
LICENSE="MIT" # https://github.com/dotnet/buildtools/blob/master/LICENSE

#	dev-dotnet/newtonsoft-json
COMMON_DEPEND=">=dev-lang/mono-5.2.0.196
	dev-dotnet/msbuild-tasks-api
	=dev-dotnet/newtonsoft-json-6.0.8-r1[gac]
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

PROJ1=Microsoft.DotNet.Build.Tasks
PROJ1_DIR=src/Microsoft.DotNet.Build.Tasks

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

	VER=1.0.27.0
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
	insinto "/usr/lib/mono/xbuild"
	doins "${S}/src/Microsoft.DotNet.Build.Tasks/PackageFiles/resources.targets"
	if use symlink; then
		dosym "/usr/$(get_libdir)/mono/gac/${PROJ1}/1.0.27.0__0738eb9f132ed756/${PROJ1}.dll" "/usr/lib/mono/xbuild/${PROJ1}.dll"
	fi
}
