# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
KEYWORDS="~amd64"

RESTRICT="mirror"

SLOT="0"

# debug = debug configuration (symbols and defines for debugging)
# developer = generate symbols information (to view line numbers in stack traces, either in debug or release configuration)
# test = allow NUnit tests to run
# nupkg = create .nupkg file from .nuspec
# gac = install into gac
# pkg-config = register in pkg-config database
USE_DOTNET="net45"
inherit msbuild gac
IUSE="+${USE_DOTNET}"

NAME="irony"
HOMEPAGE="https://github.com/daxnet/${NAME}"

EGIT_COMMIT="ed2aa3ed74b53b1655a2b196d34a1bc20d4e6ce1"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PF}.tar.gz
	https://github.com/mono/mono/raw/master/mcs/class/mono.snk"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="parsing framework for C# on LALR(1)"
LICENSE="MIT"

CDEPEND="|| ( >=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999 )
	"

RDEPEND="${CDEPEND}
	"

DEPEND="${CDEPEND}
	>=dev-dotnet/msbuildtasks-1.5.0.240-r3
	"

PROJECT_PATH="src/Irony"
PROJECT_NAME=Irony
PROJECT_OUT=Irony

KEY2="${DISTDIR}/mono.snk"
ASSEMBLY_VERSION="1.0.2017.0831"

function output_filename ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "${PROJECT_PATH}/bin/${DIR}/${PROJECT_OUT}.dll"
}

src_prepare() {
	sed -i "/Version/d" "${S}/${PROJECT_PATH}/Properties/AssemblyInfo.cs" || die
	cp "${FILESDIR}/template.csproj" "${S}/${PROJECT_PATH}/${PROJECT_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.Xml" />#' "${S}/${PROJECT_PATH}/${PROJECT_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.Numerics" />#' "${S}/${PROJECT_PATH}/${PROJECT_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="Microsoft.CSharp" />#' "${S}/${PROJECT_PATH}/${PROJECT_NAME}.csproj" || die
	eapply_user
}

src_compile() {
	emsbuild /p:RootNamespace=Irony /p:SignAssembly=true /p:PublicSign=true "/p:AssemblyOriginatorKeyFile=${KEY2}" "/p:OutputName=${PROJECT_OUT}" "/p:OutputType=Library" "/p:VersionNumber=${ASSEMBLY_VERSION}" "${S}/${PROJECT_PATH}/${PROJECT_NAME}.csproj"
	sn -R "$(output_filename)" "${KEY2}" || die
}

src_install() {
	insinto "/gac"
	doins "$(output_filename)"
}

pkg_preinst()
{
	echo mv "${D}/gac/${PROJECT_OUT}.dll" "${T}/${PROJECT_OUT}.dll"
	mv "${D}/gac/${PROJECT_OUT}.dll" "${T}/${PROJECT_OUT}.dll" || die
	echo rm -rf "${D}/gac"
	rm -rf "${D}/gac" || die
}

pkg_postinst()
{
	egacadd "${T}/${PROJECT_OUT}.dll"
	rm "${T}/${PROJECT_OUT}.dll" || die
}

pkg_prerm()
{
	egacdel "${PROJECT_OUT}, Version=${ASSEMBLY_VERSION}, Culture=neutral, PublicKeyToken=0738eb9f132ed756"
}
