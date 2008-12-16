# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/libgdiplus/libgdiplus-2.0.ebuild,v 1.2 2008/11/25 00:02:37 loki_val Exp $

EAPI=2

inherit flag-o-matic toolchain-funcs

DESCRIPTION="Library for using System.Drawing with mono"
HOMEPAGE="http://www.go-mono.com/"
SRC_URI="http://mono.ximian.com/mono-packagers/libgdiplus-2.2.tar.bz2 -> ${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86 ~x86-fbsd"
IUSE="pango +exif +jpeg +tiff +gif"

RDEPEND=">=dev-libs/glib-2.6
		>=media-libs/freetype-2
		>=media-libs/fontconfig-2
		media-libs/libpng
		x11-libs/libXrender
		x11-libs/libX11
		x11-libs/libXt
		x11-libs/cairo[X]
		exif? ( media-libs/libexif )
		gif? ( >=media-libs/giflib-4.1.3 )
		jpeg? ( media-libs/jpeg )
		tiff? ( media-libs/tiff )
		pango? ( x11-libs/pango )"
DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.19"

RESTRICT="test"

S=${WORKDIR}/${P%_pre*}

src_configure() {
	if [[ "$(gcc-major-version)" -gt "3" ]] || \
	   ( [[ "$(gcc-major-version)" -eq "3" ]] && [[ "$(gcc-minor-version)" -gt "3" ]] )
	then
		append-flags -fno-inline-functions
	fi

	# Disable glitz support as libgdiplus does not use it, and it causes errors
	econf	--disable-dependency-tracking		\
		--with-cairo=system			\
		$(use pango && printf %b --with-pango)			\
		$(use_with tiff libtiff)		\
		$(use_with exif libexif)		\
		$(use_with jpeg libjpeg)		\
		$(use_with gif libgif)			\
		|| die "configure failed"
}

src_compile() {
	emake || die "compile failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS ChangeLog NEWS README
}
