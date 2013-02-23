# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/libgdiplus/Attic/libgdiplus-9999.ebuild,v 1.7 2011/02/27 12:46:28 pacho dead $

EAPI=2

EGIT_REPO_URI="http://github.com/mono/${PN}.git"

inherit go-mono mono flag-o-matic git-2 autotools

DESCRIPTION="Library for using System.Drawing with mono"
HOMEPAGE="http://www.go-mono.com/"

SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="cairo"

RDEPEND=">=dev-libs/glib-2.16
		>=media-libs/freetype-2.3.7
		>=media-libs/fontconfig-2.6
		>=media-libs/libpng-1.4:0
		x11-libs/libXrender
		x11-libs/libX11
		x11-libs/libXt
		>=x11-libs/cairo-1.8.4[X]
		media-libs/libexif
		>=media-libs/giflib-4.1.3
		virtual/jpeg
		media-libs/tiff:0
		!cairo? ( >=x11-lzhibs/pango-1.20 )"
DEPEND="${RDEPEND}"

RESTRICT="test"

PATCHES=(
	"${FILESDIR}/${PN}-2.10.1-libpng15.patch"
)

src_prepare() {
	sed -i -e 's/LT_/LTT_/g' cairo/configure.in || die
	go-mono_src_prepare
	epatch "${FILESDIR}/${PN}-2.10.9-gold.patch"
	sed -i -e 's:ungif:gif:g' configure || die
}

src_configure() {
	append-flags -fno-strict-aliasing
	go-mono_src_configure	--with-cairo=system			\
				$(use !cairo && printf %s --with-pango)	\
				|| die "configure failed"
}
