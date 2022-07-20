# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
KEYWORDS="~amd64"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"
inherit msbuild gac
IUSE="+${USE_DOTNET}"

NAME="SpecFlow"
HOMEPAGE="https://www.specflow.org/"

EGIT_COMMIT="d79e211e94860f0c98fb43264e4358714da1fd95"
SRC_URI="https://github.com/techtalk/${NAME}/archive/${EGIT_COMMIT}.tar.gz -> ${PF}.tar.gz
	https://github.com/mono/mono/raw/main/mcs/class/mono.snk"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="Binding business requirements to .Net code"
LICENSE="BSD" # https://github.com/techtalk/SpecFlow/blob/master/LICENSE.txt

CDEPEND="|| ( >=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999 )
	"
RDEPEND="${CDEPEND}
"
DEPEND="${CDEPEND}
"

PATH_TO_PROJ="Runtime"
METAFILE_TO_BUILD="TechTalk.SpecFlow"
ASSEMBLY_NAME="TechTalk.SpecFlow"

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
	#cp "${FILESDIR}/CommonAssemblyInfo-${PV}.cs" "${S}/${PATH_TO_PROJ}/../CommonAssemblyInfo.cs" || die
	eapply_user
}

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
