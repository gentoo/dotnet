# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
KEYWORDS="~amd64"

RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"
inherit msbuild gac
IUSE="+${USE_DOTNET}"

NAME="Core"
HOMEPAGE="https://www.castleproject.org"

EGIT_COMMIT="9a033d8a69535e9078a3344e1ceddf18b60f9324"
SRC_URI="https://github.com/castleproject/${NAME}/archive/${EGIT_COMMIT}.tar.gz -> ${PF}.tar.gz
	https://github.com/mono/mono/raw/main/mcs/class/mono.snk"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="simple set of tools to speed up the development"
LICENSE="Apache-2.0" # https://github.com/castleproject/Core/blob/master/LICENSE

CDEPEND="|| ( >=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999 )
	"

RDEPEND="${CDEPEND}
	"

DEPEND="${CDEPEND}
	"

PROJECT_PATH1="Core/Castle.Core"
PROJECT_PATH2="Tools/Castle.DynamicProxy2/Castle.DynamicProxy"
PROJECT_NAME1="Castle.Core-vs2008"
PROJECT_NAME2="Castle.DynamicProxy-vs2008"
PROJECT_OUT1="Castle.Core"
PROJECT_OUT2="Castle.DynamicProxy2"

KEY2="${DISTDIR}/mono.snk"
ASSEMBLY_VERSION="2.1.0.0"

function output_filename1 ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "${PROJECT_PATH1}/bin/${DIR}/${PROJECT_OUT1}.dll"
}

function output_filename2 ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "${PROJECT_PATH2}/bin/${DIR}/${PROJECT_OUT2}.dll"
}

src_prepare() {
	# copy (replace) project files
	cp "${FILESDIR}/${PROJECT_NAME1}-${PV}.csproj" "${S}/${PROJECT_PATH1}/${PROJECT_NAME1}.csproj" || die
	cp "${FILESDIR}/${PROJECT_NAME2}-${PV}.csproj" "${S}/${PROJECT_PATH2}/${PROJECT_NAME2}.csproj" || die
	# create version info files
	cat <<-METADATA >"${S}/Core/Castle.Core/AssemblyInfo.cs" || die
	    [assembly: System.Reflection.AssemblyVersion("2.1.0.0")]
	METADATA
	cat <<-METADATA >"${S}/Tools/Castle.DynamicProxy2/Castle.DynamicProxy/AssemblyInfo.cs" || die
	    [assembly: System.Reflection.AssemblyVersion("2.1.0.0")]
	METADATA
	# other initialization
	eapply_user
}

src_compile() {
	emsbuild /p:SignAssembly=true /p:PublicSign=true "/p:AssemblyOriginatorKeyFile=${KEY2}" "${S}/${PROJECT_PATH2}/${PROJECT_NAME2}.csproj"
	sn -R "$(output_filename1)" "${KEY2}" || die
	sn -R "$(output_filename2)" "${KEY2}" || die
}

src_install() {
	insinto "/gac"
	doins "$(output_filename1)"
	doins "$(output_filename2)"
}

pkg_preinst()
{
	echo mv "${D}/gac/${PROJECT_OUT1}.dll" "${T}/${PROJECT_OUT1}.dll"
	echo mv "${D}/gac/${PROJECT_OUT2}.dll" "${T}/${PROJECT_OUT2}.dll"
	mv "${D}/gac/${PROJECT_OUT1}.dll" "${T}/${PROJECT_OUT1}.dll" || die
	mv "${D}/gac/${PROJECT_OUT2}.dll" "${T}/${PROJECT_OUT2}.dll" || die
	echo rm -rf "${D}/gac"
	rm -rf "${D}/gac" || die
}

pkg_postinst()
{
	egacadd "${T}/${PROJECT_OUT1}.dll"
	egacadd "${T}/${PROJECT_OUT2}.dll"
	rm "${T}/${PROJECT_OUT1}.dll" || die
	rm "${T}/${PROJECT_OUT2}.dll" || die
}

pkg_prerm()
{
	egacdel "${PROJECT_OUT1}, Version=${ASSEMBLY_VERSION}, Culture=neutral, PublicKeyToken=0738eb9f132ed756"
	egacdel "${PROJECT_OUT2}, Version=${ASSEMBLY_VERSION}, Culture=neutral, PublicKeyToken=0738eb9f132ed756"
}
