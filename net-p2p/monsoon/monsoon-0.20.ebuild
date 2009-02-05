# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit mono multilib autotools

DESCRIPTION="Monosoon is an open source Gtk# bittorrent client"
HOMEPAGE="http://www.monsoon-project.org/"
SRC_URI="http://monotorrent.com/Files/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RDEPEND=">=dev-dotnet/monotorrent-0.70
	>=dev-dotnet/mono-nat-1.0
	>=dev-dotnet/nlog-1.0"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.23"

#This sucks, but the install process is screwed up if it's set.
unset LINGUAS

src_prepare() {
	epatch "${FILESDIR}/${P}-build.patch"
	eautoreconf
}

src_compile() {
	emake -j1 ASSEMBLY_COMPILER_COMMAND="/usr/bin/gmcs"
}

src_install() {
	emake -j1 DESTDIR="${D}" install
	sed -i -e "s;@expanded_libdir@;/usr/$(get_libdir);" \
		"${D}/usr/bin/monsoon" || die "Fixing monsoon failed."
}
