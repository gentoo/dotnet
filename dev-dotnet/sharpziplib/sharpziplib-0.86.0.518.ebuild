# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
KEYWORDS="~amd64 ~ppc ~x86"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"
inherit msbuild gac
IUSE="+${USE_DOTNET}"

NAME="SharpZipLib"
HOMEPAGE="https://github.com/icsharpcode/${NAME}"

EGIT_COMMIT="cfc69a68fefbc5858fe70b35f7b69fc505b8c2d6"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PF}.tar.gz"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="Zip, GZip, Tar and BZip2 library written entirely in C# for the .NET platform"
LICENSE="MIT" # Actually not, it is GPL with exception - http://icsharpcode.github.io/SharpZipLib/

COMMON_DEPENDENCIES="|| ( >=dev-lang/mono-4.2 <dev-lang/mono-9999 )"
RDEPEND="${COMMON_DEPENDENCIES}
"
DEPEND="${COMMON_DEPENDENCIES}
"

METAFILETOBUILD=old-ICSharpCode.SharpZLib
PROJECT_DIRECTORY="src"
ASSEMBLY_NAME="ICSharpCode.SharpZLib"

function output_file ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "${PROJECT_DIRECTORY}/bin/${DIR}/${ASSEMBLY_NAME}.dll"
}

src_prepare() {
	cp "${FILESDIR}/${METAFILETOBUILD}-${PV}.csproj" "${S}/${PROJECT_DIRECTORY}/${METAFILETOBUILD}.csproj" || die
	eapply_user
}

# SNK_FILENAME=ICSharpCode.SharpZipLib.key
#TOOLS_VERSION=12.0
TOOLS_VERSION=4.0

src_compile() {
	emsbuild "${S}/${PROJECT_DIRECTORY}/${METAFILETOBUILD}.csproj"
}

src_install() {
	:;
}

