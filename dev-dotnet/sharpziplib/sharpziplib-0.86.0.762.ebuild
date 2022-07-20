# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
KEYWORDS="~amd64"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"
inherit msbuild gac
IUSE="+${USE_DOTNET}"

NAME="SharpZipLib"
HOMEPAGE="https://github.com/icsharpcode/${NAME}"

EGIT_COMMIT="4ad264b562579fc8d0c1f73812f69b78b49ebdee"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PF}.tar.gz
	https://github.com/mono/mono/raw/main/mcs/class/mono.snk"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="Zip, GZip, Tar and BZip2 library written entirely in C# for the .NET platform"
LICENSE="MIT" # Actually not, it is GPL with exception - https://icsharpcode.github.io/SharpZipLib/

#	dev-dotnet/system-security-cryptography-algorithms
CDEPEND="|| ( >=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999 )
	"
RDEPEND="${CDEPEND}
"
DEPEND="${CDEPEND}
	>=dev-dotnet/msbuildtasks-1.5.0.240
"

PATH_TO_PROJ="src"
METAFILE_TO_BUILD=old-ICSharpCode.SharpZLib
ASSEMBLY_NAME="ICSharpCode.SharpZLib"

KEY2="${DISTDIR}/mono.snk"
ASSEMBLY_VERSION="${PV}"

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
	cp "${FILESDIR}/${METAFILE_TO_BUILD}-${PV}.csproj" "${S}/${PATH_TO_PROJ}/${METAFILE_TO_BUILD}.csproj" || die
	eapply_user
}

# SNK_FILENAME=ICSharpCode.SharpZipLib.key
#TOOLS_VERSION=12.0
TOOLS_VERSION=4.0

src_compile() {
	emsbuild /p:TargetFrameworkVersion=v4.6 "/p:SignAssembly=true" "/p:PublicSign=true" "/p:AssemblyOriginatorKeyFile=${KEY2}" /p:VersionNumber="${ASSEMBLY_VERSION}" "${S}/${PATH_TO_PROJ}/${METAFILE_TO_BUILD}.csproj"
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
