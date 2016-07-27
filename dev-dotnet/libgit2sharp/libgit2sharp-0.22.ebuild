# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

USE_DOTNET="net45"
IUSE="${USE_DOTNET}"

inherit nuget nupkg

KEYWORDS="amd64 x86 ~ppc-macos"

DESCRIPTION="A C# PInvoke wrapper library for LibGit2 C library"

EGIT_COMMIT="8daef23223e1374141bf496e4b310ded9ae4639e"
HOMEPAGE="https://github.com/libgit2/libgit2sharp"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
#RESTRICT="mirror"

S="${WORKDIR}/${PN}-${EGIT_COMMIT}"

LICENSE="MIT"
SLOT="0"

CDEPEND="
	dev-libs/libgit2
"

DEPEND="${CDEPEND}
	dev-dotnet/nuget
"
RDEPEND="${CDEPEND}"

src_unpack() {
	default
	# remove rogue binaries
	rm -rf "${S}/Lib/NuGet/" || die
	rm -rf "${S}/Lib/CustomBuildTasks/CustomBuildTasks.dll" || die
}

src_prepare() {
	eapply "${FILESDIR}/sln.patch"
	eapply "${FILESDIR}/csproj-remove-nuget-targets-check.patch"
	eapply "${FILESDIR}/packages-config-remove-xunit.patch"
	eapply "${FILESDIR}/remove-NativeBinaries-package-dependency.patch"
	echo "/usr/lib64/libgit2.so" >"LibGit2Sharp/libgit2_filename.txt" || die
	enuget_restore "LibGit2Sharp.sln"
	default
}

src_compile() {
	# recreate custom build tasks .dll
	sed -i "s#<OutputPath>.*</OutputPath>#<OutputPath>.</OutputPath>#g" "Lib/CustomBuildTasks/CustomBuildTasks.csproj" || die
	exbuild "Lib/CustomBuildTasks/CustomBuildTasks.csproj"

	# main compileation
	exbuild "LibGit2Sharp.sln"
}
