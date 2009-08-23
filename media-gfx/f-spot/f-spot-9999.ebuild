# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/f-spot/f-spot-0.5.0.3-r1.ebuild,v 1.3 2009/02/01 21:15:58 mr_bones_ Exp $

EAPI=2

EGIT_REPO_URI="git://git.gnome.org/f-spot"

inherit gnome2 mono eutils git autotools

DESCRIPTION="Personal photo management application for the gnome desktop"
HOMEPAGE="http://f-spot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""
SRC_URI=""

RDEPEND=">=dev-lang/mono-2.0
	>=dev-libs/dbus-glib-0.71
	>=dev-libs/glib-2
	>=x11-libs/gtk+-2.6
	>=dev-dotnet/gtk-sharp-2.12.0
	>=dev-dotnet/glade-sharp-2.12.0
	>=dev-dotnet/dbus-sharp-0.4.2
	>=dev-dotnet/dbus-glib-sharp-0.3.0
	>=dev-dotnet/gtkhtml-sharp-2.7
	>=dev-dotnet/gconf-sharp-2.7
	>=dev-dotnet/gnomevfs-sharp-2.7
	>=gnome-base/libgnome-2.2
	>=gnome-base/libgnomeui-2.2
	>=media-libs/libexif-0.6.16
	<media-libs/libexif-0.7.0
	>=media-libs/libgphoto2-2.1.4
	>=media-libs/lcms-1.15
	media-libs/jpeg
	>=dev-db/sqlite-3"

DEPEND="${RDEPEND}
	app-text/gnome-doc-utils
	dev-util/pkgconfig
	>=dev-util/intltool-0.29"

DOCS="AUTHORS ChangeLog MAINTAINERS NEWS README"

MAKEOPTS="${MAKEOPTS} -j1"

# See bug #203566
# RESTRICT="test"

src_prepare() {
	gnome-doc-prepare --copy || die "Failed running gnome-doc-prepare"
	glib-gettextize --force --copy || die "Failed running glib-gettextize"
	intltoolize --copy --force --automake || die "Failed running intltoolize"
	eautoreconf

	gnome2_src_prepare

	sed -i -e '/DISABLE_DEPRECATED/d' $(find . -name 'Makefile.in') || die "Disabling DISABLE_DEPRECATED failed"
}

src_configure() {
	gnome2_src_configure --disable-static --disable-dependency-tracking
}

src_install() {
	gnome2_src_install
	find "${D}" -name '*.la' -exec rm -rf '{}' '+' || die "la removal failed"
}
