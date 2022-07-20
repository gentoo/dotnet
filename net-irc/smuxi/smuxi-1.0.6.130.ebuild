# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils gnome2-utils mono-env versionator

DESCRIPTION="A flexible, irssi-like and user-friendly IRC client for the Gnome Desktop"
HOMEPAGE="https://www.smuxi.org/main/"

SRC_URI="https://github.com/ArsenShnurkov/shnurise-tarballs/archive/${CATEGORY}/${PN}/${PN}-${PV}.tar.gz"
S="${WORKDIR}/shnurise-tarballs-${CATEGORY}-${PN}-${PN}-${PV}"

SLOT="0"
KEYWORDS="~amd64"
IUSE="dbus debug gtk libnotify spell"
LICENSE="|| ( GPL-2 GPL-3 )"

CDEPEND=">=dev-lang/mono-4.0.2.5
	>=dev-dotnet/smartirc4net-1.0
	dev-libs/stfl
	>=dev-dotnet/log4net-1.2.10
	>=dev-dotnet/nini-1.1.0-r2
	gtk? ( >=dev-dotnet/gtk-sharp-2.12.21:2 )
	libnotify? ( >=dev-dotnet/notify-sharp-0.4 )
	libnotify? ( <dev-dotnet/notify-sharp-3 )
	dbus? ( >=dev-dotnet/dbus-sharp-glib-0.6:* )
	spell? ( >=app-text/gtkspell-2.0.9:2 )
"
DEPEND="${CDEPEND}
	>=dev-util/intltool-0.25
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"
RDEPEND="${CDEPEND}"

pkg_preinst() {
	gnome2_icon_savelist
}

src_prepare() {
	default
}

src_configure() {
	# Our dev-dotnet/db4o is completely unmaintained
	# We don't have ubuntu stuff
	econf \
	--enable-engine-irc		\
	--without-indicate		\
	--with-vendor-package-version="Gentoo ${PV}" \
	--with-db4o=included \
	--with-messaging-menu=no \
	--with-indicate=no \
	$(use_enable debug)		\
	$(use_enable gtk frontend-gnome) \
	$(use_with libnotify notify) \
	$(use_with spell gtkspell)

	touch README
}

src_compile() {
	default
}

src_install() {
	default

	# desktop icon is installed with /usr/share/applications/smuxi-frontend-gnome.desktop
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
