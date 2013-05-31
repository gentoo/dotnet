# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit dotnet autotools base

SLOT="2"
KEYWORDS="~amd64 ~x86"
SRC_URI="http://ftp.gnome.org/pub/gnome/sources/gnome-sharp/2.24/${PN}-${PV}.tar.bz2"
IUSE="debug"

RESTRICT="test"

RDEPEND="
	>=dev-dotnet/gtk-sharp-2.12.21
	gnome-base/gconf
	gnome-base/libgnomecanvas
	gnome-base/libgnomeui
	media-libs/libart_lgpl
	"
DEPEND="${RDEPEND}
	sys-devel/automake:1.11"

src_prepare() {
	base_src_prepare || die
	eautoreconf || die
	libtoolize || die
}

src_configure() {
	econf \
		$(use_enable debug) \
		|| die
}

src_compile() {
	emake || die
}

src_install() {
	default
	dotnet_multilib_comply || die
}
