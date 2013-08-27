# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit dotnet autotools versionator

SLOT="2"
DESCRIPTION="gnome-desktop mono bindings"
HOMEPAGE="http://www.mono-project.com/GtkSharp"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86 ~ppc"
MVER="$(get_version_component_range 1-2)"
SRC_URI="mirror://gnome/sources/gnome-desktop-sharp/${MVER}/${P}.tar.bz2"
IUSE="debug panel gtkhtml print gtksourceview rsvg vte wnck"

RESTRICT="test"

RDEPEND="
	>=dev-dotnet/gtk-sharp-2.12.21
	>=dev-dotnet/gnome-sharp-2.24.2-r1
	gnome-base/gnome-desktop:2
	panel? ( =gnome-base/gnome-panel-2* )
	gtkhtml? ( =gnome-extra/gtkhtml-3* )
	print? ( gnome-base/libgnomeprint:2.2 gnome-base/libgnomeprintui:2.2 )
	gtksourceview? ( x11-libs/gtksourceview:2.0 )
	rsvg? ( gnome-base/librsvg:2 )
	vte? ( x11-libs/vte:0 )
	wnck? ( x11-libs/libwnck:1 )
	!dev-dotnet/gnome-panel-sharp
	!dev-dotnet/gnome-print-sharp
	!dev-dotnet/gtkhtml-sharp
	!dev-dotnet/gtksourceview-sharp
	!dev-dotnet/nautilusburn-sharp
	!dev-dotnet/rsvg-sharp
	!dev-dotnet/vte-sharp
	!dev-dotnet/wnck-sharp
	"
DEPEND="${RDEPEND}
	sys-devel/automake:1.11"

src_prepare() {
	base_src_prepare
	eautoreconf
	elibtoolize
}

src_configure() {
	econf $(use_enable debug)
}

src_install() {
	default
	dotnet_multilib_comply
}
