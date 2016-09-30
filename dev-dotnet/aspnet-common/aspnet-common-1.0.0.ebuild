# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
SLOT="0"

KEYWORDS="~amd64 ~ppc ~x86"
USE_DOTNET="net45"

inherit gac dotnet

SRC_URI="https://github.com/aspnet/Common/archive/1.0.0.tar.gz -> ${PN}-${PV}.tar.gz"
RESTRICT="mirror"
S="${WORKDIR}/Common-${PV}"

HOMEPAGE="https://github.com/aspnet/Common"
DESCRIPTION="A repository for shared files to be consumed across the ASPNET repos"
LICENSE="Apache-2.0" # https://github.com/aspnet/Common/blob/dev/LICENSE.txt

IUSE="+${USE_DOTNET} +debug developer doc"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_unpack() {
	default
	#gunzip --decompress --stdout "${FILESDIR}/Autofac.csproj-${PV}.gz" >"${S}/src/Autofac/Autofac.csproj" || die
}

src_prepare() {
	eapply_user
}

src_compile() {
	#exbuild_strong /p:VersionNumber=${PV} "src/Autofac/Autofac.csproj"
	:;
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	#egacinstall "src/Autofac/bin/${DIR}/Autofac.dll"
	#einstall_pc_file "${PN}" "${PV}" "Autofac.dll"
}
