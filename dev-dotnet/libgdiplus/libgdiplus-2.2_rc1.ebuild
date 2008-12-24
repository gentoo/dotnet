# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/libgdiplus/libgdiplus-2.0.ebuild,v 1.2 2008/11/25 00:02:37 loki_val Exp $

EAPI=2

inherit go-mono mono flag-o-matic

DESCRIPTION="Library for using System.Drawing with mono"
HOMEPAGE="http://www.go-mono.com/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86 ~x86-fbsd"
IUSE="pango"

RDEPEND=">=dev-libs/glib-2.6
		>=media-libs/freetype-2
		>=media-libs/fontconfig-2
		media-libs/libpng
		x11-libs/libXrender
		x11-libs/libX11
		x11-libs/libXt
		x11-libs/cairo[X]
		media-libs/libexif
		>=media-libs/giflib-4.1.3
		media-libs/jpeg
		media-libs/tiff
		pango? ( x11-libs/pango-1.20 )"
DEPEND="${RDEPEND}"

RESTRICT="test"

src_configure() {
	go-mono_src_configure	--with-cairo=system			\
				$(use pango && printf %b --with-pango)	\
				|| die "configure failed"
}

