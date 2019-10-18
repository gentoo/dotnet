# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils gnome2-utils mono-env dotnet versionator autotools git-r3

DESCRIPTION="A flexible, irssi-like and user-friendly IRC client for the Gnome Desktop"
HOMEPAGE="https://www.smuxi.org/main/"
EGIT_REPO_URI="https://github.com/meebey/smuxi"
# https://github.com/meebey/smuxi/releases/tag/1.0.7
#EGIT_COMMIT="a63e6236bb241c018633c380c99554c38a83f6ad"
#EGIT_BRANCH="release/1.0"

SRC_URI=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dbus debug gtk libnotify spell nls"
LICENSE="|| ( GPL-2 GPL-3 )"

CDEPEND=">=dev-lang/mono-4.0.2.5
	>=dev-dotnet/smartirc4net-1.0
	dev-libs/stfl
	>=dev-dotnet/log4net-1.2.10
	>=dev-dotnet/nini-1.1.0-r2
	gtk? ( >=dev-dotnet/gtk-sharp-2.12.39:2 )
	libnotify? ( >=dev-dotnet/notify-sharp-0.4 )
	libnotify? ( <dev-dotnet/notify-sharp-3 )
	dbus? ( >=dev-dotnet/dbus-sharp-glib-0.6:* )
	spell? ( >=app-text/gtkspell-2.0.9:2 )
"
DEPEND="${CDEPEND}
	>=dev-util/intltool-0.25
	>=sys-devel/gettext-0.17
	>=net-misc/x11-ssh-askpass-1.2.4.1-r1
	virtual/pkgconfig
"
RDEPEND="${CDEPEND}"

# Build failed on debug issue with --jobs > 1 (2017-07-31)
MAKEOPTS="-j1"

pkg_preinst() {
	gnome2_icon_savelist
}

src_prepare() {
	default

	# https://github.com/meebey/smuxi/issues/86
	# eautoreconf
	./autogen.sh || die "Could not run autogen.sh"
}

src_configure() {
	# Our dev-dotnet/db4o is completely unmaintained
	# We don't have ubuntu stuff
	econf                   \
	CSC=/usr/bin/mcs        \
	--enable-engine-irc     \
	--without-indicate      \
	--with-vendor-package-version="Gentoo ${PV}" \
	--with-db4o=included \
	--with-messaging-menu=no \
	--with-indicate=no \
	$(use_enable debug)     \
	$(use_enable gtk frontend-gnome) \
	$(use_enable nls)       \
	$(use_with libnotify notify) \
	$(use_with spell gtkspell) \

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
