# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} developer debug nupkg gac doc"

inherit msbuild

NAME="tartool"
HOMEPAGE="https://github.com/senthilrajasek/${NAME}"

EGIT_COMMIT="7b22774e464e1a0de547e776236a1631db9f1037"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="command line tool to uncompress and untar .tar.gz (.tgz) files"
LICENSE="MIT" # https://github.com/senthilrajasek/tartool/blob/master/LICENSE

CDEPEND=">=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999
"

RDEPEND="${CDEPEND}
"

DEPEND="${CDEPEND}
"

PATH_TO_PROJ="Tools.CommandLine/trunk/Tools.CommandLine.TarTool"
METAFILE_TO_BUILD=Tools.CommandLine
ASSEMBLY_NAME="TarTool"

#ASSEMBLY_VERSION="${PV}"

function output_filename ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "${PATH_TO_PROJ}/bin/${DIR}/${ASSEMBLY_NAME}.exe"
}

src_prepare() {
	eapply_user
}

src_compile() {
	emsbuild /p:TargetFrameworkVersion=v4.6 "/p:SignAssembly=true" "/p:PublicSign=true" "/p:AssemblyOriginatorKeyFile=${KEY2}" /p:VersionNumber="${ASSEMBLY_VERSION}" "${S}/${PATH_TO_PROJ}/${METAFILE_TO_BUILD}.csproj"
}

src_install() {
	if [ "${SLOT}" eq "0"]
	then
		SLOTTEDDIR="/usr/share/${PN}/"
	else
		SLOTTEDDIR="/usr/share/${PN}-${SLOT}/"
	fi
	insinto "${SLOTTEDDIR}"
	doins "${PATH_TO_PROJ}/bin/${DIR}/${ASSEMBLY_NAME}.{config,dll,exe}"
	if use developer; then
		doins "${PATH_TO_PROJ}/bin/${DIR}/${ASSEMBLY_NAME}.pdb"
	fi

	make_wrapper nunit "mono ${SLOTTEDDIR}/${ASSEMBLY_NAME}.exe"
}
