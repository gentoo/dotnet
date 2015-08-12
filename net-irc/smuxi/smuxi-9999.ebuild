# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils mono-env git-2 autotools-utils

DESCRIPTION="A flexible, irssi-like and user-friendly IRC client for the Gnome Desktop"
HOMEPAGE="http://www.smuxi.org/main/"

SLOT="0"
KEYWORDS=""
IUSE="dbus debug gtk libnotify spell" #-gtk3 ( gtk3 branch just broken )
LICENSE="|| ( GPL-2 GPL-3 )"

RDEPEND="
	>=dev-lang/mono-3.0
	>=dev-dotnet/smartirc4net-0.4.5.1
	>=dev-dotnet/nini-1.1.0-r2
	>=dev-dotnet/log4net-1.2.10
	dbus? (	dev-dotnet/ndesk-dbus
		dev-dotnet/ndesk-dbus-glib )
	gtk? ( >=dev-dotnet/gtk-sharp-2.12:2 )
	libnotify? ( dev-dotnet/notify-sharp )
	spell? ( >=app-text/gtkspell-2.0.9:2 )
"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.25
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"

EGIT_REPO_URI="git://github.com/meebey/smuxi.git"
EGIT_MASTER="master"
EGIT_HAS_SUBMODULES=1

DOCS=( FEATURES README.md )
AUTOTOOLS_IN_SOURCE_BUILD=1

src_prepare() {
	./autogen.sh MCS=$(which dmcs) || die
}

src_configure() {
	local myeconfargs=(
		--enable-engine-irc
		--without-indicate
		--with-vendor-package-version="Gentoo"
		--with-db4o=included
		--with-messaging-menu=no
		--with-indicate=no
		--disable-engine-jabbr
		$(use_enable debug)
		$(use_enable gtk frontend-gnome)
		$(use_with libnotify notify)
		$(use_with spell gtkspell)
	)
	autotools-utils_src_configure
}

src_install() {
	default
	#runner scripts fix
	sed -i -e 's@mono --debug@mono --runtime=v4.0@g' "${ED}"/usr/bin/smuxi-frontend-gnome || die
	sed -i -e 's@mono --debug@mono --runtime=v4.0@g' "${ED}"/usr/bin/smuxi-server || die
}
