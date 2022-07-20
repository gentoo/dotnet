# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KEYWORDS="~amd64"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"

inherit dotnet msbuild gac

NAME="Relinq-EagerFetching"
HOMEPAGE="https://github.com/re-motion/${NAME}"
EGIT_COMMIT="9c3fe22e35f3f66becc197829d8e3bdf8e3dd622"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${NAME}-${PV}.tar.gz
	https://github.com/mono/mono/raw/main/mcs/class/mono.snk"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="Library to create full-featured LINQ providers (fetching)."
LICENSE="LGPL-2.1" # https://github.com/re-motion/Relinq-EagerFetching/blob/develop/license/LGPLv2.1.txt

IUSE="+${USE_DOTNET} +msbuild debug developer doc"

COMMON_DEPEND=">=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999
	dev-dotnet/remotion-linq
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

# https://github.com/re-motion/Relinq/blob/82fdca6a4bfd942bb4a71dd20ab9c5af0aea0541/How%20to%20build.txt
# We cannot provide the official remotion.snk keyfile, so you will need to create your own.
KEY2="${DISTDIR}/mono.snk"

METAFILE_FOR_BUILD="${S}/Core/Core.csproj"
ASSEMBLY_NAME="Remotion.Linq.EagerFetching"

function output_filename ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "Core/bin/${DIR}/${ASSEMBLY_NAME}.dll"
}

function deploy_dir ( ) {
	echo "/usr/$(get_libdir)/mono/${EBUILD_FRAMEWORK}"
}

pkg_setup() {
	dotnet_pkg_setup
}

src_prepare() {
	eapply "${FILESDIR}/Core.csproj.patch"
	eapply_user
}

src_compile() {
	emsbuild /p:TargetFrameworkVersion=v4.6 "/p:SignAssembly=true" "/p:PublicSign=true" "/p:AssemblyOriginatorKeyFile=${KEY2}" "${METAFILE_FOR_BUILD}"
	sn -R "${S}/$(output_filename)" "${KEY2}" || die
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
	egacdel "${ASSEMBLY_NAME}, Version=2.1.0.0, Culture=neutral, PublicKeyToken=0738eb9f132ed756"
}
