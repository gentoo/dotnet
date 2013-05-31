# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit dotnet autotools base

SLOT="2"
KEYWORDS="~amd64 ~x86"
SRC_URI="http://download.mono-project.com/sources/gtk-sharp212/${P}.tar.gz"
IUSE="debug"

RESTRICT="test"

RDEPEND="
	>=dev-lang/mono-3.0
	>=dev-util/pkgconfig-0.9
	x11-libs/pango
	>=dev-libs/glib-2.31
	dev-libs/atk
	x11-libs/gtk+:2
	gnome-base/libglade
	dev-perl/XML-LibXML"
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
	sed -i "s/\\r//g" "${D}"/usr/bin/* || die
}
