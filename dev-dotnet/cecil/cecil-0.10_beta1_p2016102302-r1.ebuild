# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

RESTRICT+="mirror"

inherit gac nupkg

HOMEPAGE="https://cecil.pe/"
DESCRIPTION="System.Reflection alternative to generate and inspect .NET executables/libraries"
# https://github.com/jbevain/cecil/wiki/License
# https://github.com/jbevain/cecil/blob/master/LICENSE.txt
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
USE_DOTNET="net45 net35"
IUSE="+${USE_DOTNET} +gac +nupkg +pkg-config +debug +developer"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"

RDEPEND="${COMMON_DEPEND}
"

DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"

NAME="cecil"
REPO_OWNER="jbevain"
REPOSITORY="https://github.com/${REPO_OWNER}/${NAME}"
LICENSE_URL="${REPOSITORY}/blob/master/LICENSE"
ICONMETA="https://www.iconeasy.com/icon/ico/Movie%20%26%20TV/Looney%20Tunes/Cecil%20Turtle%20no%20shell.ico"
ICON_URL="file://${FILESDIR}/cecil_turtle_no_shell.png"

EGIT_BRANCH="master"
EGIT_COMMIT="68bcb750b898f4882a5af44299bb322aaa531f93"
SRC_URI="https://api.github.com/repos/${REPO_OWNER}/${NAME}/tarball/${EGIT_COMMIT} -> ${PF}.tar.gz"
RESTRICT+=" test"
S="${WORKDIR}/${NAME}-${EGIT_BRANCH}"

METAFILETOBUILD="./Mono.Cecil.sln"

GAC_DLL_NAME=Mono.Cecil

NUSPEC_ID="Mono.Cecil"
NUSPEC_FILE="${S}/Mono.Cecil.nuspec"
NUSPEC_VERSION="0.10.0.2016102302"

src_prepare() {
	enuget_restore "${METAFILETOBUILD}"

	eapply "${FILESDIR}/nuspec-${PV}.patch"
	eapply "${FILESDIR}/csproj-${PV}.patch"
	eapply "${FILESDIR}/sln-${PV}.patch"

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
		P_FW_VERSION="/p:TargetFrameworkVersion=v${FW_UPPER}.${FW_LOWER}"
		local CONFIGURATION=""
		if use debug; then
			CONFIGURATION=net_${FW_UPPER}_${FW_LOWER}_Debug
		else
			CONFIGURATION=net_${FW_UPPER}_${FW_LOWER}_Debug
		fi
		einfo "Building configuration '${CONFIGURATION}'"
		P_CONFIGURATION="/p:Configuration=${CONFIGURATION}"
		exbuild_raw ${PARAMETERS} ${P_FW_VERSION} ${P_CONFIGURATION} "${METAFILETOBUILD}"
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

	einstall_pc_file "${PN}" "0.10" "${GAC_DLL_NAME}"
}
