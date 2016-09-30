# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
SLOT="0"

KEYWORDS="~amd64 ~ppc ~x86"
USE_DOTNET="net45"

inherit gac dotnet

SRC_URI="https://github.com/loresoft/msbuildtasks/archive/1.5.0.196.tar.gz -> ${PV}.tar.gz"
RESTRICT="mirror"
S="${WORKDIR}/${PN}-${PV}"

HOMEPAGE="https://github.com/loresoft/msbuildtasks"
DESCRIPTION="The MSBuild Community Tasks Project is an open source project for MSBuild tasks."
LICENSE="BSD" # https://github.com/loresoft/msbuildtasks/blob/master/LICENSE

IUSE="+${USE_DOTNET} +debug developer doc"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
	=dev-dotnet/dotnetzip-semverd-1.9.3-r1
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_prepare() {
	eapply "${FILESDIR}/references-2016052301.patch"
	eapply "${FILESDIR}/location.patch"
	eapply_user
}

src_compile() {
	exbuild "Source/MSBuild.Community.Tasks/MSBuild.Community.Tasks.csproj"
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	egacinstall "Source/MSBuild.Community.Tasks/bin/${DIR}/MSBuild.Community.Tasks.dll"
	einstall_pc_file "${PN}" "${PV}" "MSBuild.Community.Tasks.dll"
	insinto "/usr/lib/mono/4.5"
	doins "Source/MSBuild.Community.Tasks/MSBuild.Community.Tasks.Targets"
}
