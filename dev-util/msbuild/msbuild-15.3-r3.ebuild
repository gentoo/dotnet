# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"
KEYWORDS="~amd64"
SLOT="0"

USE_DOTNET="net46"
IUSE="+${USE_DOTNET} +gac developer debug doc +roslyn"

inherit dotnet xbuild gac

GITHUB_ACCOUNT="mono"
GITHUB_PROJECTNAME="linux-packaging-msbuild"
EGIT_COMMIT="e08c20fd277b9de1e3a97c5bd9a5dcf95fcff926"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${GITHUB_PROJECTNAME}-${GITHUB_ACCOUNT}-${PV}.tar.gz
	https://github.com/mono/mono/raw/master/mcs/class/mono.snk"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

HOMEPAGE="https://docs.microsoft.com/visualstudio/msbuild/msbuild"
DESCRIPTION="Microsoft Build Engine (MSBuild), XML-based platform for building applications"
LICENSE="MIT" # https://github.com/mono/linux-packaging-msbuild/blob/master/LICENSE

COMMON_DEPEND=">=dev-lang/mono-5.2.0.196
	dev-dotnet/msbuild-tasks-api developer? ( dev-dotnet/msbuild-tasks-api[developer] )
	dev-dotnet/msbuild-defaulttasks developer? ( dev-dotnet/msbuild-defaulttasks[developer] )
	roslyn? ( dev-dotnet/msbuild-roslyn-csc )
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	dev-dotnet/buildtools
"

KEY2="${DISTDIR}/mono.snk"

PROJ1=Microsoft.Build
PROJ1_DIR=src/Build
PROJ2=MSBuild
PROJ2_DIR=src/MSBuild

VER=15.3.0.0

src_prepare() {
	eapply "${FILESDIR}/dir.props.diff"
	eapply "${FILESDIR}/dir.targets.diff"
	eapply "${FILESDIR}/src-dir.targets.diff"
	eapply "${FILESDIR}/tasks.patch"
	eapply "${FILESDIR}/Microsoft.CSharp.targets.patch"
	eapply "${FILESDIR}/Microsoft.Common.targets.patch"
	sed -i 's/CurrentAssemblyVersion = "15.1.0.0"/CurrentAssemblyVersion = "15.3.0.0"/g' "${S}/src/Shared/Constants.cs" || die
	sed -i 's/Microsoft.Build.Tasks.Core, Version=15.1.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a/Microsoft.Build.Tasks.Core, Version=15.3.0.0, Culture=neutral, PublicKeyToken=0738eb9f132ed756/g' "${S}/src/Tasks/Microsoft.Common.tasks" || die
	sed -i 's/PublicKeyToken=b03f5f7f11d50a3a/PublicKeyToken=0738eb9f132ed756/g' "${S}/src/Build/Resources/Constants.cs" || die
	cp "${FILESDIR}/mono-${PROJ1}.csproj" "${S}/${PROJ1_DIR}/" || die
	cp "${FILESDIR}/mono-${PROJ2}.csproj" "${S}/${PROJ2_DIR}/" || die
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

	exbuild_raw /v:detailed /p:TargetFrameworkVersion=v4.6 "/p:Configuration=${CONFIGURATION}" ${SARGS} "/p:VersionNumber=${VER}" "/p:RootPath=${S}" "/p:SignAssembly=true" "/p:AssemblyOriginatorKeyFile=${KEY2}" "${S}/${PROJ2_DIR}/mono-${PROJ2}.csproj"
	sn -R "${PROJ1_DIR}/bin/${CONFIGURATION}/${PROJ1}.dll" "${KEY2}" || die
}

src_install() {
	if use debug; then
		CONFIGURATION=Debug
	else
		CONFIGURATION=Release
	fi

	egacinstall "${PROJ1_DIR}/bin/${CONFIGURATION}/${PROJ1}.dll"

	insinto "/usr/share/${PN}"
	newins "${PROJ2_DIR}/bin/${CONFIGURATION}/${PROJ2}.exe" MSBuild.exe
	doins "${S}/src/Tasks/Microsoft.Common.props"
	doins "${S}/src/Tasks/Microsoft.Common.targets"
	doins "${S}/src/Tasks/Microsoft.Common.overridetasks"
	doins "${S}/src/Tasks/Microsoft.CSharp.targets"
	doins "${S}/src/Tasks/Microsoft.CSharp.CurrentVersion.targets"
	doins "${S}/src/Tasks/Microsoft.Common.CurrentVersion.targets"
	doins "${S}/src/Tasks/Microsoft.NETFramework.props"
	doins "${S}/src/Tasks/Microsoft.NETFramework.CurrentVersion.props"
	doins "${S}/src/Tasks/Microsoft.NETFramework.targets"
	doins "${S}/src/Tasks/Microsoft.NETFramework.CurrentVersion.targets"

	if use debug; then
		make_wrapper msbuild "/usr/bin/mono --debug /usr/share/${PN}/MSBuild.exe"
	else
		make_wrapper msbuild "/usr/bin/mono /usr/share/${PN}/MSBuild.exe"
	fi
}
