# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

KEYWORDS="~amd64 ~ppc ~x86"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"

inherit dotnet msbuild gac

NAME="antlrcs"
HOMEPAGE="https://github.com/antlr/${NAME}"
SRC_URI="https://github.com/ArsenShnurkov/shnurise-tarballs/raw/dev-utils/antlrcs/antlrcs-3.5.2_beta1.tar.gz -> ${NAME}-${PV}.tar.gz"

DESCRIPTION="The C# port of ANTLR 3"
LICENSE="BSD" # https://github.com/antlr/antlrcs/blob/master/LICENSE.txt

IUSE="+${USE_DOTNET} debug developer doc"

COMMON_DEPEND=">=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	dev-dotnet/antlr3-runtime
"

TASKSASSEMBLY="AntlrBuildTask/old-AntlrBuildTask.csproj"
ASSEMBLY_NAME="AntlrBuildTask"
EXECUTABLE_PROJ="Antlr3/old-Antlr3.csproj"
EXECUTABLE_NAME="Antlr3"

function tasksassembly_file ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "AntlrBuildTask/bin/${DIR}/${ASSEMBLY_NAME}.dll"
}

function executable_file ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "Antlr3/bin/${DIR}/${EXECUTABLE}.exe"
}

src_prepare() {
	cp "${FILESDIR}/old-AntlrBuildTask.csproj" "${S}/${TASKSASSEMBLY}" || die
	cp "${FILESDIR}/old-Antlr3.csproj" "${S}/${EXECUTABLE_PROJ}" || die
	eapply_user
}

src_compile() {
	emsbuild /p:TargetFrameworkVersion=v4.6 "${S}/${TASKSASSEMBLY}"
	emsbuild /p:TargetFrameworkVersion=v4.6 "${S}/${EXECUTABLE_PROJ}"
}

TASKS_PROPS_FILE="AntlrBuildTask/Antlr3.props"
TASKS_TARGETS_FILE="AntlrBuildTask/Antlr3.targets"

src_install() {
	einstask "${S}/$(tasksassembly_file)" "${S}/${TASKS_PROPS_FILE}" "${S}/${TASKS_TARGETS_FILE}"
}
