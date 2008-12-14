# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/beagle/beagle-0.2.18-r1.ebuild,v 1.2 2008/10/11 22:54:52 eva Exp $

EAPI=1

inherit gnome.org eutils autotools mono

DESCRIPTION="search tool that ransacks your personal information space to find whatever you're looking for"
HOMEPAGE="http://www.beagle-project.org"

LICENSE="MIT Apache-1.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="chm doc eds galago gtk ole pdf python thunderbird +xscreensaver"

RDEPEND=">=dev-lang/mono-1.1.18
	app-arch/zip
	sys-devel/gettext
	>=x11-libs/gtk+-2.6
	=dev-libs/gmime-2.2*
	>=dev-dotnet/gtk-sharp-2.8
	>=gnome-base/librsvg-2
	>=media-libs/libexif-0.6
	>=dev-libs/libxml2-2.6.19
	x11-libs/libX11
	x11-libs/libXt
	>=dev-db/sqlite-3.3.1
	gtk? ( >=dev-dotnet/gconf-sharp-2.8
		>=dev-dotnet/glade-sharp-2.8
		>=dev-dotnet/gnome-sharp-2.8 )
	eds? ( >=dev-dotnet/evolution-sharp-0.13.3
		>=dev-dotnet/gconf-sharp-2.3 )
	ole? ( >=app-text/wv-1.2.0
		>=dev-dotnet/gsf-sharp-0.6
		>=app-office/gnumeric-1.4.3-r3 )
	python? ( >=dev-python/pygtk-2.6 )
	pdf? ( >=app-text/poppler-0.5.1 )
	chm? ( dev-libs/chmlib )
	galago? ( >=dev-dotnet/galago-sharp-0.5 )
	xscreensaver? ( x11-libs/libXScrnSaver )
	!dev-libs/libbeagle"
DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
	dev-util/pkgconfig
	x11-proto/xproto
	xscreensaver? ( x11-proto/scrnsaverproto )
	>=dev-util/intltool-0.23"

pkg_setup() {
	local fail="Re-emerge dev-libs/gmime with USE mono."

	if ! built_with_use dev-libs/gmime mono; then
		eerror "${fail}"
		die "${fail}"
	fi

	enewgroup beagleindex
	enewuser beagleindex -1 -1 /var/lib/cache/beagle beagleindex
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Multilib fix
	sed -i -e 's:prefix mono`/lib:libdir mono`:' \
		"${S}"/configure.in || die "sed failed"

	epatch "${FILESDIR}"/${PN}-0.2.7-crawltweek.patch
	epatch "${FILESDIR}"/${PN}-log-level-warn.patch
	epatch "${FILESDIR}"/${P}-mono-1.9.1.patch

	eautoreconf
	intltoolize --force || die "intltoolize failed"
}

src_compile() {
	econf --enable-libbeagle --enable-sqlite3 \
		$(use_enable doc gtk-doc) \
		$(use_enable thunderbird) \
		$(use_enable eds evolution) \
		$(use_enable gtk gui) \
		$(use_enable python) \
		$(use_enable ole gsf-sharp) \
		$(use_enable xscreensaver xss)

	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."

	dodir /usr/share/beagle
	insinto /usr/share/beagle
	doins mozilla-extension/beagle.xpi

	dodoc AUTHORS NEWS README

	sed -i -e 's/CRAWL_ENABLED="yes"/CRAWL_ENABLED="no"/' "${D}"/etc/beagle/crawl-*

	insinto /etc/beagle
	doins "${FILESDIR}"/crawl-portage

	keepdir /usr/$(get_libdir)/beagle/Backends
	diropts -o beagleindex -g beagleindex
	keepdir /var/lib/cache/beagle/indexes
}

pkg_postinst() {
	elog "If available, Beagle greatly benefits from using certain operating"
	elog "system features such as Extended Attributes and inotify."
	echo
	elog "If you want static queryables such as the portage tree and system"
	elog "documentation you will need to edit the /etc/beagle/crawl-* files"
	elog "and change CRAWL_ENABLE from 'no' to 'yes'."
	echo
	elog "For more info on how to create the optimal beagle environment, and"
	elog "basic usage info, see the Gentoo page of the Beagle website:"
	elog "http://www.beagle-project.org/Gentoo_Installation"
}
