# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

USE_DOTNET="net45"
IUSE="${USE_DOTNET}"

inherit nupkg

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
    nuget restore ${S}/LibGit2Sharp.sln || die
}

src_prepare() {
	eapply "${FILESDIR}/sln.patch"
	default
}
