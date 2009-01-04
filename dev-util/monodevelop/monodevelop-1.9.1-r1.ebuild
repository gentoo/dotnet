# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/monodevelop/monodevelop-1.9.1.ebuild,v 1.8 2008/12/15 23:21:42 loki_val Exp $

EAPI=2

inherit fdo-mime mono multilib gnome2-utils autotools

DESCRIPTION="Integrated Development Environment for .NET"
HOMEPAGE="http://www.monodevelop.com/"
SRC_URI="http://www.go-mono.com/sources/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+subversion"

RDEPEND=">=dev-lang/mono-1.9
		 >=virtual/monodoc-1.9
		 ||	(
			~dev-dotnet/mono-addins-0.3.1
			>=dev-dotnet/mono-addins-0.4[gtk]
			)
		 >=dev-dotnet/gtk-sharp-2.12.6[glade]
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
		 dev-util/ctags"

DEPEND="${RDEPEND}
		  sys-devel/gettext
		  x11-misc/shared-mime-info
		>=dev-util/intltool-0.35
		>=dev-util/pkgconfig-0.19"

MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	sed -i -e '/SUBDIRS/ s/contrib//' Makefile.am
	find .	\
		-name "*.am" \
		-exec perl -pe \
			's!-r:\$\(top_(src|build)dir\)/(contrib|build/bin)/Mono.Cecil.dll!-pkg:cecil!g' -i {} \; \
		|| die "sed Mono.Cecil.dll failed"
	find .	\
		-name "*.am" \
		-exec perl -pe \
			's!-r:\$\(top_(src|build)dir\)/(contrib|build/bin)/Mono.Cecil.Mdb.dll!!g' -i {} \; \
		|| die "sed Mono.Cecil.Mdb.dll failed"
	epatch "${FILESDIR}/${P}-use-system-stetic.patch"
	eautoreconf
}


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
	elog " - dev-util/monodevelop-java"
	elog " - dev-util/monodevelop-boo"
	elog " - dev-util/monodevelop-database"
	elog "To enable their (self-explanatory) functionality, just emerge them."
	elog "Read more here:"
	elog "http://monodevelop.com/"

}
