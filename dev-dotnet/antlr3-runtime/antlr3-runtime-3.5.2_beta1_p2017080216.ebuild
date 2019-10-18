# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KEYWORDS="~amd64"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"

inherit dotnet msbuild gac

NAME="antlrcs"
HOMEPAGE="https://github.com/antlr/${NAME}"
EGIT_COMMIT="ca331b7109e1faa5a6aa7336bb6281ce9363e62b"
SRC_URI="https://github.com/ArsenShnurkov/shnurise-tarballs/raw/dev-utils/${PN}-${SLOT}/${PN}-${PV}.tar.gz -> ${NAME}-${PV}.tar.gz
	https://github.com/mono/mono/raw/master/mcs/class/mono.snk"
S="${WORKDIR}"

DESCRIPTION="The C# port of ANTLR 3 (Rubtime library)"
LICENSE="BSD" # https://github.com/antlr/antlrcs/blob/master/LICENSE.txt

IUSE="+${USE_DOTNET} debug developer doc"

COMMON_DEPEND=">=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	>=dev-dotnet/msbuildtasks-1.5.0.240
"

PATH_TO_PROJ="Runtime/Antlr3.Runtime"
METAFILE_TO_BUILD="old-Antlr3.Runtime.csproj"
ASSEMBLY_NAME="Antlr3.Runtime"

KEY2="${DISTDIR}/mono.snk"
ASSEMBLY_VERSION="3.5.1.26"

function output_filename ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "${PATH_TO_PROJ}/bin/${DIR}/${ASSEMBLY_NAME}.dll"
}

src_prepare() {
	cp "${FILESDIR}/${METAFILE_TO_BUILD}" "${S}/${PATH_TO_PROJ}/" || die
	eapply_user
}

src_compile() {
	emsbuild /p:TargetFrameworkVersion=v4.6 "/p:SignAssembly=true" "/p:PublicSign=true" "/p:AssemblyOriginatorKeyFile=${KEY2}" /p:VersionNumber="${ASSEMBLY_VERSION}" "${S}/${PATH_TO_PROJ}/${METAFILE_TO_BUILD}"
	sn -R "$(output_filename)" "${KEY2}" || die
}

src_install() {
	insinto "/gac"
	doins "$(output_filename)"
}

pkg_preinst()
{
	echo mv "${D}/gac/${ASSEMBLY_NAME}.dll" "${T}/${ASSEMBLY_NAME}.dll"
	mv "${D}/gac/${ASSEMBLY_NAME}.dll" "${T}/${ASSEMBLY_NAME}.dll" || die
	echo rm -rf "${D}/gac"
	rm -rf "${D}/gac" || die
}

pkg_postinst()
{
	egacadd "${T}/${ASSEMBLY_NAME}.dll"
	rm "${T}/${ASSEMBLY_NAME}.dll" || die
}

pkg_prerm()
{
	egacdel "${ASSEMBLY_NAME}, Version=${ASSEMBLY_VERSION}, Culture=neutral, PublicKeyToken=0738eb9f132ed756"
}
