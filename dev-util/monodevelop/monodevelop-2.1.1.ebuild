# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/monodevelop/monodevelop-2.0.ebuild,v 1.1 2009/03/30 18:56:43 loki_val Exp $

EAPI=2

inherit fdo-mime mono multilib gnome2-utils

DESCRIPTION="Integrated Development Environment for .NET"
HOMEPAGE="http://www.monodevelop.com/"
SRC_URI="http://ftp.novell.com/pub/mono/sources/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+subversion"

RDEPEND="sys-apps/dbus[X]
	>=dev-lang/mono-2.4
	>=virtual/monodoc-2.0
	||	(
		>=dev-dotnet/mono-addins-0.4[gtk]
		~dev-dotnet/mono-addins-0.3.1
	)
	>=dev-dotnet/gtk-sharp-2.12.9
	>=dev-dotnet/glade-sharp-2.12.9
	>=dev-dotnet/gnome-sharp-2.24.0
	>=dev-dotnet/gnomevfs-sharp-2.24.0
	>=dev-dotnet/gconf-sharp-2.24.0
	||	(
		net-libs/xulrunner
		www-client/mozilla-firefox
		www-client/mozilla-firefox-bin
		www-client/seamonkey
	)
	>=dev-dotnet/xsp-2
	subversion? ( dev-util/subversion )
	dev-util/ctags
	!<dev-util/monodevelop-boo-${PV}
	!<dev-util/monodevelop-java-${PV}
	!<dev-util/monodevelop-database-${PV}
	!<dev-util/monodevelop-debugger-gdb-${PV}
	!<dev-util/monodevelop-debugger-mdb-${PV}
	!<dev-util/monodevelop-vala-${PV}"

DEPEND="${RDEPEND}
	sys-devel/gettext
	x11-misc/shared-mime-info
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.19"

MAKEOPTS="${MAKEOPTS} -j1"

src_configure() {
	econf	--disable-update-mimedb				\
		--disable-update-desktopdb			\
		--enable-monoextensions				\
		--enable-versioncontrol				\
		--disable-gtksourceview2			\
		--enable-gnomeplatform				\
		$(use_enable subversion)			\
		|| die "configure failed"
}

src_compile() {
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc ChangeLog README || die "dodoc failed"
}

pkg_postinst() {
	gnome2_icon_cache_update
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update
	elog "These optional plugins currently exist:"
	elog " - dev-util/monodevelop-boo"
	elog " - dev-util/monodevelop-java"
	elog " - dev-util/monodevelop-database"
	elog " - dev-util/monodevelop-debugger-gdb"
	elog " - dev-util/monodevelop-debugger-mdb"
	elog " - dev-util/monodevelop-vala"
	elog "To enable their (self-explanatory) functionality, just emerge them."
	elog "Read more here:"
	elog "http://monodevelop.com/"
}
