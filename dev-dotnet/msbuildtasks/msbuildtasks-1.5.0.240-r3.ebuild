# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
SLOT="0"

KEYWORDS="~amd64"
USE_DOTNET="net45"

inherit dotnet gac mono-pkg-config

IUSE="+${USE_DOTNET} +debug developer doc xbuild"

HOMEPAGE="https://github.com/loresoft/msbuildtasks"
EGIT_COMMIT="014ed0f7a69f4936d7b3b438a5ceca78f902e0ef"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz
	https://github.com/mono/mono/raw/main/mcs/class/mono.snk"
RESTRICT="mirror"
NAME="msbuildtasks"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="The MSBuild Community Tasks Project is an open source project for MSBuild tasks."
LICENSE="BSD" # https://github.com/loresoft/msbuildtasks/blob/master/LICENSE

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
	>=dev-dotnet/dotnetzip-semverd-1.9.3-r2
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

KEY2="${DISTDIR}/mono.snk"

function metafile_to_build ( ) {
	echo "Source/MSBuild.Community.Tasks/MSBuild.Community.Tasks.csproj"
}

function output_filename ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "Source/MSBuild.Community.Tasks/bin/${DIR}/MSBuild.Community.Tasks.dll"
}

function deploy_dir ( ) {
	echo "/usr/lib/mono/${EBUILD_FRAMEWORK}"
}

src_prepare() {
	eapply "${FILESDIR}/remove-sandcastle-task.patch"
	eapply "${FILESDIR}/csproj.patch"
	eapply "${FILESDIR}/location.patch"
	sed -i 's/Microsoft.Build.Framework/Microsoft.Build.Framework, Version=15.3.0.0, Culture=neutral, PublicKeyToken=0738eb9f132ed756/g' "$(metafile_to_build)" || die
	sed -i 's/Microsoft.Build.Utilities.v4.0/Microsoft.Build.Utilities.Core, Version=15.3.0.0, Culture=neutral, PublicKeyToken=0738eb9f132ed756/g' "$(metafile_to_build)" || die
	eapply_user
}

src_compile() {
	exbuild_strong "$(metafile_to_build)"
	sn -R "$(output_filename)" "${KEY2}" || die
}

src_install() {
	insinto "$(deploy_dir)"
	doins "$(output_filename)"
	einstall_pc_file "${PN}" "${PV}" "MSBuild.Community.Tasks"

	insinto "/usr/share/msbuild"
	doins "Source/MSBuild.Community.Tasks/MSBuild.Community.Tasks.Targets"

	if use xbuild; then
		insinto "/usr/lib/mono/xbuild"
		dosym "${EPREFIX}/usr/share/msbuild/MSBuild.Community.Tasks.Targets" "/usr/lib/mono/xbuild/MSBuild.Community.Tasks.Targets"
	fi
}

pkg_postinst()
{
	egacadd "$(deploy_dir)/MSBuild.Community.Tasks.dll"
}

pkg_prerm()
{
	egacdel "MSBuild.Community.Tasks"
}
