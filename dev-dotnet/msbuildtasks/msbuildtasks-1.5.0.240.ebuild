# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
SLOT="0"

KEYWORDS="~amd64"
USE_DOTNET="net45"

inherit gac dotnet

HOMEPAGE="https://github.com/loresoft/msbuildtasks"
EGIT_COMMIT="014ed0f7a69f4936d7b3b438a5ceca78f902e0ef"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
RESTRICT="mirror"
NAME="msbuildtasks"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

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
	eapply "${FILESDIR}/csproj.patch"
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
	insinto "/usr/lib/mono/${EBUILD_FRAMEWORK}"
	doins "Source/MSBuild.Community.Tasks/bin/${DIR}/MSBuild.Community.Tasks.dll"
	einstall_pc_file "${PN}" "${PV}" "MSBuild.Community.Tasks"
	insinto "/usr/lib/mono/xbuild"
	doins "Source/MSBuild.Community.Tasks/MSBuild.Community.Tasks.Targets"
}

pkg_postinst()
{
	egacadd "usr/lib/mono/${EBUILD_FRAMEWORK}/MSBuild.Community.Tasks.dll"
}

pkg_prerm()
{
	egacdel "MSBuild.Community.Tasks"
}
