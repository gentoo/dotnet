# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
KEYWORDS="~amd64 ~x86"

RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"
inherit msbuild gac
IUSE="+${USE_DOTNET}"

NAME="Core"
HOMEPAGE="http://www.castleproject.org"

EGIT_COMMIT="9a033d8a69535e9078a3344e1ceddf18b60f9324"
SRC_URI="https://github.com/castleproject/${NAME}/archive/${EGIT_COMMIT}.tar.gz -> ${PF}.tar.gz
	https://github.com/mono/mono/raw/master/mcs/class/mono.snk"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="simple set of tools to speed up the development"
LICENSE="Apache-2.0" # https://github.com/castleproject/Core/blob/master/LICENSE

CDEPEND="|| ( >=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999 )
	"

RDEPEND="${CDEPEND}
	"

DEPEND="${CDEPEND}
	"

PROJECT_PATH="Tools/Castle.DynamicProxy2/Castle.DynamicProxy"
PROJECT_NAME="Castle.DynamicProxy-vs2008"
PROJECT_OUT="CastleCore.DynamicProxy2"

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
	#cp "${FILESDIR}/${PROJECT_NAME}-${PV}.csproj" "${S}/${PROJECT_PATH}/${PROJECT_NAME}.csproj" || die
	cat <<-METADATA >"${S}/Core/Castle.Core/AssemblyInfo.cs" || die
	    [assembly: System.Reflection.AssemblyVersion("2.1.0.0")]
	METADATA
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
