# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

RESTRICT="mirror"
KEYWORDS="~amd64"
SLOT="0"

USE_DOTNET="net46"
IUSE="+${USE_DOTNET} gac developer debug doc"

inherit dotnet xbuild gac

GITHUB_ACCOUNT="mono"
GITHUB_PROJECTNAME="linux-packaging-msbuild"
EGIT_COMMIT="e08c20fd277b9de1e3a97c5bd9a5dcf95fcff926"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${GITHUB_PROJECTNAME}-${GITHUB_ACCOUNT}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

HOMEPAGE="https://docs.microsoft.com/visualstudio/msbuild/msbuild"
DESCRIPTION="default tasks for Microsoft Build Engine (MSBuild)"
LICENSE="MIT" # https://github.com/mono/linux-packaging-msbuild/blob/master/LICENSE

COMMON_DEPEND=">=dev-lang/mono-5.2.0.196
	dev-dotnet/msbuild-tasks-api developer? ( dev-dotnet/msbuild-tasks-api[developer] )
	dev-dotnet/system-reflection-metadata developer? ( dev-dotnet/system-reflection-metadata[developer] )
	dev-dotnet/system-collections-immutable developer? ( dev-dotnet/system-collections-immutable[developer] )
"

RDEPEND="${COMMON_DEPEND}
"

DEPEND="${COMMON_DEPEND}
	dev-dotnet/buildtools
"

KEY2="${FILESDIR}/mono.snk"

PROJ0=Microsoft.Build.Tasks
PROJ0_DIR=src/Tasks

METAFILE_FO_BUILD="${S}/${PROJ0_DIR}/${PROJ0}.csproj"

function output_filename ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "${S}/bin/${DIR}/x86/Unix/Output/${PROJ0}.Core.dll"
}

src_prepare() {
	eapply "${FILESDIR}/dir.props.diff"
	eapply "${FILESDIR}/dir.targets.diff"
	eapply "${FILESDIR}/src-dir.targets.diff"
	eapply "${FILESDIR}/tasks.patch"
	sed -i 's/CurrentAssemblyVersion = "15.1.0.0"/CurrentAssemblyVersion = "15.3.0.0"/g' "${S}/src/Shared/Constants.cs" || die
	sed -i 's/Microsoft.Build.Tasks.Core, Version=15.1.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a/Microsoft.Build.Tasks.Core, Version=15.3.0.0, Culture=neutral, PublicKeyToken=0738eb9f132ed756/g' "${S}/src/Tasks/Microsoft.Common.tasks" || die
	sed -i 's/PublicKeyToken=b03f5f7f11d50a3a/PublicKeyToken=0738eb9f132ed756/g' "${S}/src/Build/Resources/Constants.cs" || die
	eapply_user
}

src_compile() {
	if use developer; then
		SARGS=/p:DebugSymbols=True
	else
		SARGS=/p:DebugSymbols=False
	fi

	if use debug; then
		CONFIGURATION=Debug
		if use developer; then
			SARGS=${SARGS} /p:DebugType=full
		fi
	else
		CONFIGURATION=Release
		if use developer; then
			SARGS=${SARGS} /p:DebugType=pdbonly
		fi
	fi

	VER="1.0.27.0"

	exbuild_raw /v:detailed  /p:MonoBuild=true /p:TargetFrameworkVersion=v4.6 "/p:Configuration=${CONFIGURATION}" ${SARGS} "/p:VersionNumber=${VER}" "/p:RootPath=${S}" "/p:SignAssembly=true" "/p:AssemblyOriginatorKeyFile=${KEY2}" "${METAFILE_FO_BUILD}"
	sn -R "$(output_filename)" "${KEY2}" || die
}

src_install() {
	egacinstall "$(output_filename)"

	insinto "/usr/share/msbuild/"
	doins "$(output_filename)"
	doins "${FILESDIR}/Microsoft.Common.tasks"
}
