# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
SLOT="4"

KEYWORDS="~amd64"
USE_DOTNET="net45"

inherit gac dotnet

SRC_URI="https://github.com/autofac/Autofac/archive/v4.1.1.tar.gz -> ${PN}-${PV}.tar.gz"
RESTRICT="mirror"
S="${WORKDIR}/Autofac-${PV}"

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

src_unpack() {
	default
	gunzip --decompress --stdout "${FILESDIR}/Autofac.csproj-${PV}.gz" >"${S}/src/Autofac/Autofac.csproj" || die
}

src_prepare() {
	eapply_user
}

src_compile() {
	exbuild_strong /p:VersionNumber=${PV} "src/Autofac/Autofac.csproj"
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	egacinstall "src/Autofac/bin/${DIR}/Autofac.dll"
	einstall_pc_file "${PN}" "${PV}" "Autofac"
}
