# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

RESTRICT+=" mirror"

inherit nupkg gac

HOMEPAGE="https://cecil.pe/"
DESCRIPTION="System.Reflection alternative to generate and inspect .NET executables/libraries"
# https://github.com/jbevain/cecil/wiki/License
# https://github.com/jbevain/cecil/blob/master/LICENSE.txt
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
USE_DOTNET="net35 net40 net45"
IUSE="net35 net40 net45 +gac +nupkg +pkg-config debug developer"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"

RDEPEND="${COMMON_DEPEND}
"

DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"

REPO_OWNER="jbevain"
NAME="cecil"
REPOSITORY="https://github.com/${REPO_OWNER}/${NAME}"
LICENSE_URL="${REPOSITORY}/blob/master/LICENSE"
ICONMETA="https://github.com/lontivero/Open.NAT/tree/gh-pages/images/logos"
ICON_URL="file://${FILESDIR}/nuget_icon_64x64.png"

EGIT_BRANCH="master"
EGIT_COMMIT="0e24ced7e3e9dd8320f450b6cb1d981bf9412cf8"
SRC_URI="https://api.github.com/repos/${REPO_OWNER}/${NAME}/tarball/${EGIT_COMMIT} -> ${PF}.tar.gz"
#S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
S="${WORKDIR}/${NAME}-${EGIT_BRANCH}"

METAFILETOBUILD="./Mono.Cecil.sln"

GAC_DLL_NAME=Mono.Cecil

NUSPEC_ID="Mono.Cecil"
NUSPEC_FILE="${S}/Mono.Cecil.nuspec"
NUSPEC_VERSION="${PV//_p/.}"

src_prepare() {
	enuget_restore "${METAFILETOBUILD}"

	eapply "${FILESDIR}/nuspec.patch"

	eapply_user
}

src_configure() {
	:;
}

src_compile() {
	if [[ -z ${TOOLS_VERSION} ]]; then
		TOOLS_VERSION=4.0
	fi
	PARAMETERS=" /tv:${TOOLS_VERSION}"
	if use developer; then
		SARGS=/p:DebugSymbols=True
	else
		SARGS=/p:DebugSymbols=False
	fi
	PARAMETERS+=" ${SARGS}"
	PARAMETERS+=" /p:SignAssembly=true"
	PARAMETERS+=" /p:AssemblyOriginatorKeyFile=${WORKDIR}/mono.snk"
	PARAMETERS+=" /v:detailed"

	for x in ${USE_DOTNET} ; do
		FW_UPPER=${x:3:1}
		FW_LOWER=${x:4:1}
		PARAMETERS_2=" /p:TargetFrameworkVersion=v${FW_UPPER}.${FW_LOWER}"
		if use debug; then
			CARGS=/p:Configuration=net_${FW_UPPER}_${FW_LOWER}_Debug
		else
			CARGS=/p:Configuration=net_${FW_UPPER}_${FW_LOWER}_Release
		fi
		PARAMETERS_2+=" ${CARGS}"
		exbuild_raw ${PARAMETERS} ${PARAMETERS_2} "${METAFILETOBUILD}"
	done

	# run nuget_pack
	enuspec -Prop "id=${NUSPEC_ID};version=${NUSPEC_VERSION}" ${NUSPEC_FILE}
}

src_install() {
	enupkg "${WORKDIR}/${NUSPEC_ID}.${NUSPEC_VERSION}.nupkg"

	if use debug; then
		DIR=Debug
	else
		DIR=Release
	fi

	for x in ${USE_DOTNET} ; do
		FW_UPPER=${x:3:1}
		FW_LOWER=${x:4:1}
		egacinstall "bin/net_${FW_UPPER}_${FW_LOWER}_${DIR}/${GAC_DLL_NAME}.dll"
	done

	einstall_pc_file "${PN}" "0.9" "${GAC_DLL_NAME}"
}
