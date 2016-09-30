# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
SLOT="0"

KEYWORDS="~amd64 ~ppc ~x86"
USE_DOTNET="net45"

inherit gac dotnet

SRC_URI="https://github.com/autofac/Autofac/archive/v4.1.1.tar.gz -> ${PV}.tar.gz"
RESTRICT="mirror"
S="${WORKDIR}/${PN}-${PV}"

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

src_prepare() {
	#eapply "${FILESDIR}/references-2016052301.patch"
	#eapply "${FILESDIR}/location.patch"
	eapply_user
}

src_compile() {
	:;
	#exbuild "Source/MSBuild.Community.Tasks/MSBuild.Community.Tasks.csproj"
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	#egacinstall "Source/MSBuild.Community.Tasks/bin/${DIR}/MSBuild.Community.Tasks.dll"
	#einstall_pc_file "${PN}" "${PV}" "MSBuild.Community.Tasks.dll"
}
