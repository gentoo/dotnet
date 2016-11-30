# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
KEYWORDS="~amd64 ~x86"
RESTRICT+=" mirror"

USE_DOTNET="net45 net35"
IUSE="+${USE_DOTNET} +gac +nupkg +pkg-config +debug +developer"

inherit gac nupkg

HOMEPAGE="http://cecil.pe/"
DESCRIPTION="System.Reflection alternative to generate and inspect .NET executables/libraries"
# https://github.com/jbevain/cecil/wiki/License
# https://github.com/jbevain/cecil/blob/master/LICENSE.txt
LICENSE="MIT"
SLOT="0"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"

DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"

RDEPEND="${COMMON_DEPEND}
"

NAME="cecil"
REPO_OWNER="jbevain"
REPOSITORY="https://github.com/${REPO_OWNER}/${NAME}"
LICENSE_URL="${REPOSITORY}/blob/master/LICENSE"
ICONMETA="http://www.iconeasy.com/icon/ico/Movie%20%26%20TV/Looney%20Tunes/Cecil%20Turtle%20no%20shell.ico"
ICON_URL="file://${FILESDIR}/Cecil Turtle no shell.png"

EGIT_BRANCH="master"
EGIT_COMMIT="045b0f9729905dd456d46e33436a2dadc9e2a52d"
SRC_URI="https://api.github.com/repos/${REPO_OWNER}/${NAME}/tarball/${EGIT_COMMIT} -> ${PF}.tar.gz
	mirror://gentoo/mono.snk.bz2"
RESTRICT+=" test"
S="${WORKDIR}/${NAME}-${EGIT_BRANCH}"

METAFILETOBUILD="./Mono.Cecil.sln"

GAC_DLL_NAMES="Mono.Cecil Mono.Cecil.Mdb Mono.Cecil.Pdb Mono.Cecil.Rocks"

NUSPEC_ID="Mono.Cecil"
NUSPEC_FILE="${S}/Mono.Cecil.nuspec"
NUSPEC_VERSION="0.10.0.2016111002"

src_prepare() {
	enuget_restore "${METAFILETOBUILD}"

	eapply "${FILESDIR}/nuspec-${PV}.patch"
	eapply "${FILESDIR}/sln-${PV}.patch"
	#eapply "${FILESDIR}/csproj-${PV}.patch"

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
	if use debug; then
		DIR=Debug
	else
		DIR=Release
	fi

	for dll_name in ${GAC_DLL_NAMES} ; do
		for x in ${USE_DOTNET} ; do
			FW_UPPER=${x:3:1}
			FW_LOWER=${x:4:1}
			egacinstall "bin/net_${FW_UPPER}_${FW_LOWER}_${DIR}/${dll_name}.dll"
		done
	done
	einstall_pc_file "${PN}" "0.10" ${GAC_DLL_NAMES}

	enupkg "${WORKDIR}/${NUSPEC_ID}.${NUSPEC_VERSION}.nupkg"
}
