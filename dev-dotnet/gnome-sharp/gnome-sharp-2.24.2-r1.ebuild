# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit dotnet autotools base

SLOT="2"
DESCRIPTION="gnome bindings for mono"
HOMEPAGE="http://www.mono-project.com/GtkSharp"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86 ~ppc"
SRC_URI="mirror://gnome/sources/gnome-sharp/2.24/${P}.tar.bz2"
IUSE="debug"

RESTRICT="test"

RDEPEND="
	>=dev-dotnet/gtk-sharp-2.12.21
	gnome-base/gconf
	gnome-base/libgnomecanvas
	gnome-base/libgnomeui
	media-libs/libart_lgpl
	!dev-dotnet/gnomevfs-sharp
	!dev-dotnet/gconf-sharp
	!dev-dotnet/art-sharp
	"
DEPEND="${RDEPEND}
	sys-devel/automake:1.11"

src_prepare() {
	base_src_prepare

	eautoreconf || die
	elibtoolize || die
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
