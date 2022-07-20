# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
SLOT="0"

KEYWORDS="~amd64"
USE_DOTNET="net45"

inherit gac dotnet

HOMEPAGE="https://github.com/scottdorman/MSBuildContrib"
EGIT_COMMIT="47806b8bd67bb481f63cecd1b7e7d681f8d05ef4"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
RESTRICT="mirror"
NAME="MSBuildContrib"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="A project for tasks and tools that aren't part of the main MSBuild release."
LICENSE="GPL-3" # https://github.com/scottdorman/MSBuildContrib/blob/master/LICENSE

IUSE="+${USE_DOTNET} +debug developer doc"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
	=dev-dotnet/dotnetzip-semverd-1.9.3-r1
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_prepare() {
	eapply "${FILESDIR}/MSBuildContrib.Tasks.csproj.patch"
	eapply "${FILESDIR}/MSBuildContrib.Utilities.csproj.patch"
	eapply "${FILESDIR}/location.patch"
	eapply_user
}

src_compile() {
	exbuild_strong "Source/MSBuildContrib.sln"
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	insinto "/usr/lib/mono/${EBUILD_FRAMEWORK}"
	doins "Source/MSBuildContrib.Tasks/bin/${DIR}/MSBuildContrib.Tasks.dll"
	doins "Source/MSBuildContrib.Utilities/bin/${DIR}/MSBuildContrib.Utilities.dll"
	einstall_pc_file "${PN}" "${PV}" "MSBuildContrib.Tasks" "MSBuildContrib.Utilities"
	insinto "/usr/lib/mono/xbuild"
	doins "Source/MSBuildContrib.Tasks/bin/${DIR}/MSBuildContrib.Tasks"
}

pkg_postinst()
{
	egacadd "usr/lib/mono/${EBUILD_FRAMEWORK}/MSBuildContrib.Utilities.dll"
	egacadd "usr/lib/mono/${EBUILD_FRAMEWORK}/MSBuildContrib.Tasks.dll"
}

pkg_prerm()
{
	egacdel "MSBuildContrib.Tasks"
	egacdel "MSBuildContrib.Utilities"
}
