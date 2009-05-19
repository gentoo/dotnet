# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/nemerle/nemerle-0.9.3.ebuild,v 1.1 2006/10/29 07:42:04 latexer Exp $

inherit mono eutils multilib

DESCRIPTION="A hybrid programming language for the .NET platform"
HOMEPAGE="http://www.nemerle.org/"
SRC_URI="http://www.nemerle.org/download/snapshots/${P}.tar.gz"

LICENSE="nemerle"
SLOT="0"
KEYWORDS=""
IUSE=""
DEPEND=">=dev-lang/mono-1.1.9.2
		>=dev-lang/python-2.3
		>=dev-libs/libxml2-2.6.4"

src_compile() {
	./configure --net-engine=/usr/bin/mono \
		--disable-aot \
		--prefix=/usr \
		--libdir=/usr/$(get_libdir) \
		--mandir=/usr/share/man/man1 || die "configure failed!"
	emake -j1 || die "make failed!"
}

src_install() {
	make DESTDIR=${D} install || die
	dodoc AUTHORS ChangeLog INSTALL NEWS README
}
