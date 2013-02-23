# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/mono-debugger/mono-debugger-9999.ebuild $

EAPI=4

inherit go-mono mono autotools flag-o-matic eutils

DESCRIPTION="Debugger for .NET managed and unmanaged applications"
HOMEPAGE="http://www.mono-project.com/"

LICENSE="GPL-2 MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

RESTRICT="test"

# Binutils is needed for libbfd
RDEPEND="!!=dev-lang/mono-2.2
	sys-devel/binutils
	dev-libs/glib:2"
DEPEND="${RDEPEND}
	!dev-lang/mercury"

src_prepare() {
	go-mono_src_prepare

	# Allow compilation against system libbfd, bnc#662581
	epatch "${FILESDIR}/${PN}-2.8-system-bfd.patch"
	eautoreconf
}

src_configure() {
	append-ldflags -Wl,--no-undefined #nowarn

	go-mono_src_configure \
		--with-system-libbfd \
		--disable-static
}

src_compile() {
	emake -j1 #nowarn
}
