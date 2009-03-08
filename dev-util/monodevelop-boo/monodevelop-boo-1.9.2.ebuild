# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/monodevelop-boo/monodevelop-boo-1.9.1.ebuild,v 1.1 2008/11/30 12:15:19 loki_val Exp $

EAPI=2

inherit autotools eutils mono multilib

DESCRIPTION="Boo Extension for MonoDevelop"
HOMEPAGE="http://www.monodevelop.com/"
SRC_URI="http://www.go-mono.com/sources/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

RDEPEND="=dev-util/monodevelop-${PV}*
	>=dev-lang/boo-0.8.2.2960
	dev-dotnet/gtksourceview-sharp:1"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.23"

src_configure() {
	MD_BOO_CONFIG=""
	if use debug; then
		MD_BOO_CONFIG="--config=DEBUG"
	else
		MD_BOO_CONFIG="--config=RELEASE"
	fi

	./configure \
		--prefix=/usr		\
		${MD_BOO_CONFIG}	\
	|| die "configure failed"
}

src_compile() {
	emake -j1 || die "make failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "install failed"
}
