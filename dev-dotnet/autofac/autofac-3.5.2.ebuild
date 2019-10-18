# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
SLOT="3"

KEYWORDS="~amd64"

DOTNET_FRAMEWORK="net45"
USE_DOTNET="net45"

inherit msbuild gac mono-pkg-config

NAME="Autofac"
HOMEPAGE="https://github.com/Autofac/${NAME}"

EGIT_COMMIT="c985cda5483dcd4d2fbc395a4001be12cc07ee84"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz
	https://github.com/mono/mono/raw/master/mcs/class/mono.snk"
RESTRICT="mirror"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

HOMEPAGE="https://github.com/autofac/Autofac"
DESCRIPTION="An addictive .NET IoC container"
LICENSE="MIT" # https://github.com/autofac/Autofac/blob/develop/LICENSE

IUSE="+${USE_DOTNET} +debug developer doc"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

KEY2="${DISTDIR}/mono.snk"

function output_filename() {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "Core/Source/Autofac/bin/${DIR}/Autofac.dll"
}

src_prepare() {
	eapply "${FILESDIR}/Autofac.csproj-3.5.2.patch"
	#eapply "${FILESDIR}/reflection-extension-3.5.2.patch"
	eapply_user
}

src_compile() {
	emsbuild "/p:SignAssembly=true" "/p:PublicSign=true" "/p:AssemblyOriginatorKeyFile=${KEY2}" /p:VersionNumber=${PV} "Core/Source/Autofac/Autofac.csproj"
	sn -R "$(output_filename)" "${KEY2}" || die
}

src_install() {
	egacinstall "$(output_filename)"
	einstall_pc_file "${PN}" "${PV}" "Autofac"
}
