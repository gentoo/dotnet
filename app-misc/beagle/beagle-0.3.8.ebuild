# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/beagle/beagle-0.3.8.ebuild,v 1.3 2008/12/14 15:31:10 loki_val Exp $

EAPI=1

inherit gnome.org eutils autotools mono mozextension

DESCRIPTION="Search tool that ransacks your personal information space to find whatever you're looking for"
HOMEPAGE="http://www.beagle-project.org/"

LICENSE="MIT Apache-1.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="chm debug doc epiphany eds firefox galago gtk pdf inotify ole thunderbird +xscreensaver"

RDEPEND="
	>=dev-lang/mono-1.2.4
	app-shells/bash
	app-arch/zip
	sys-devel/gettext
	x11-misc/shared-mime-info
	=dev-libs/gmime-2.2*
	>=dev-libs/libxml2-2.6.19
	>=dev-db/sqlite-3.3.1
	>=dev-dotnet/dbus-sharp-0.6.0
	>=dev-dotnet/dbus-glib-sharp-0.4.1
	>=dev-dotnet/taglib-sharp-2.0
	>=dev-dotnet/gtk-sharp-2.8
	gtk? ( >=gnome-base/libgnome-2.0
		>=gnome-base/gnome-vfs-2.0
		>=dev-dotnet/gtk-sharp-2.10
		>=x11-libs/gtk+-2.10
		>=dev-libs/atk-1.2.4
		>=gnome-base/librsvg-2.0
		>=dev-dotnet/gconf-sharp-2.4
		>=dev-dotnet/glade-sharp-2.4
		>=dev-dotnet/gnome-sharp-2.4
		>=dev-dotnet/gnomevfs-sharp-2.4 )
	eds? ( >=dev-dotnet/evolution-sharp-0.13.3
		>=dev-dotnet/gconf-sharp-2.4 )
	ole? ( >=app-text/wv-1.2.3
		>=dev-dotnet/gsf-sharp-0.8
		>=app-office/gnumeric-1.4.3-r3 )
	chm? ( dev-libs/chmlib )
	pdf? ( >=app-text/poppler-0.5.1 )
	galago? ( >=dev-dotnet/galago-sharp-0.5.0 )
	thunderbird? ( || ( >=mail-client/mozilla-thunderbird-1.5
			>=mail-client/mozilla-thunderbird-bin-1.5 ) )
	firefox? ( || ( >=www-client/mozilla-firefox-1.5
			>=www-client/mozilla-firefox-bin-1.5 ) )
	epiphany? ( >=www-client/epiphany-extensions-2.16 )
	xscreensaver? ( x11-libs/libXScrnSaver )
	dev-libs/libbeagle"
	# Avahi code is currently experimental
	#avahi?	(	>=net-dns/avahi-0.6.10 )

DEPEND="${RDEPEND}
	doc? ( >=virtual/monodoc-1.2.4 )
	dev-util/pkgconfig
	xscreensaver? ( x11-proto/scrnsaverproto )
	>=dev-util/intltool-0.35"

pkg_setup() {
	local fail_gmime="Re-emerge dev-libs/gmime with USE mono."
	local fail_libbeagle="Re-emerge dev-libs/libbeagle with USE=python."
	local fail_epiphany="Re-emerge www-client/epiphany-extensions with USE=python."

	if ! built_with_use dev-libs/gmime mono; then
		eerror "${fail_gmime}"
		die "${fail_gmime}"
	fi

	if use epiphany; then
		if ! built_with_use dev-libs/libbeagle python; then
			eerror "${fail_libbeagle}"
			die "${fail_libbeagle}"
		fi
		if ! built_with_use www-client/epiphany-extensions python; then
			eerror "${fail_epiphany}"
			die "${fail_epiphany}"
		fi
	fi

	enewgroup beagleindex
	enewuser beagleindex -1 -1 /var/lib/cache/beagle beagleindex
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Multilib fix
	sed -i -e 's:prefix mono`/lib:libdir mono`:' \
		configure.in || die "sed failed"

	eautoreconf
	intltoolize --force || die "intltoolize failed"
}

src_compile() {
	econf \
		--enable-sqlite3 \
		--disable-avahi \
		--disable-internal-taglib \
		$(use_enable debug xml-dump) \
		$(use_enable doc docs) \
		$(use_enable epiphany epiphany-extension) \
		$(use_enable thunderbird) \
		$(use_enable eds evolution) \
		$(use_enable gtk gui) \
		$(use_enable ole gsf-sharp wv1) \
		$(use_enable xscreensaver xss) \
		$(use_enable inotify)
		# Avahi code is experimental, explicitly disabled above
		#$(use_enable avahi) \

	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."

	dodoc AUTHORS NEWS README

	declare MOZILLA_FIVE_HOME
	if use firefox; then
		xpi_unpack "${S}"/firefox-extension/beagle.xpi \
		|| die "Unable to find Beagle Firefox Extension"
		mv "${WORKDIR}"/beagle "${WORKDIR}"/firefox-beagle

		if has_version '>=www-client/mozilla-firefox-1.5'; then
			MOZILLA_FIVE_HOME="/usr/$(get_libdir)/mozilla-firefox"
			xpi_install "${WORKDIR}"/firefox-beagle \
			|| die "xpi install for mozilla-firefox failed!"
		fi
		if has_version '>=www-client/mozilla-firefox-bin-1.5'; then
			MOZILLA_FIVE_HOME="/opt/firefox"
			xpi_install "${WORKDIR}"/firefox-beagle \
			|| die "xpi install for mozilla-firefox-bin failed!"
		fi
	fi

	if use thunderbird; then
		xpi_unpack "${S}"/thunderbird-extension/beagle.xpi \
		|| die "Unable to find Beagle Thunderbird Extension"
		mv "${WORKDIR}"/beagle "${WORKDIR}"/thunderbird-beagle

		if has_version '>=mail-client/mozilla-thunderbird-1.5'; then
			MOZILLA_FIVE_HOME="/usr/$(get_libdir)/mozilla-thunderbird"
			xpi_install "${WORKDIR}"/thunderbird-beagle \
			|| die "xpi install for mozilla-thunderbird failed!"
		fi
		if has_version '>=mail-client/mozilla-thunderbird-bin-1.5'; then
			MOZILLA_FIVE_HOME="/opt/thunderbird"
			xpi_install "${WORKDIR}"/thunderbird-beagle \
			|| die "xpi install for mozilla-thunderbird-bin failed!"
		fi
	fi

	sed -i -e 's/CRAWL_ENABLED="yes"/CRAWL_ENABLED="no"/' \
		"${D}"/etc/beagle/crawl-rules/crawl-*

	insinto /etc/beagle/crawl-rules
	doins "${FILESDIR}/crawl-portage"

	keepdir "/usr/$(get_libdir)/beagle/Backends"
	diropts -o beagleindex -g beagleindex
	keepdir "/var/lib/cache/beagle/indexes"
}

pkg_postinst() {
	elog "If available, Beagle greatly benefits from using certain operating"
	elog "system features such as Extended Attributes and inotify."
	elog
	elog "If you want static queryables such as the portage tree and system"
	elog "documentation you will need to edit the /etc/beagle/crawl-* files"
	elog "and change CRAWL_ENABLE from 'no' to 'yes'."
	elog
	elog "For more info on how to create the optimal beagle environment, and"
	elog "basic usage info, see the Gentoo page of the Beagle website:"
	elog "http://www.beagle-project.org/Gentoo_Installation"
}
