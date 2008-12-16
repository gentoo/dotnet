# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit mono

DESCRIPTION="A simple library to embed Gecko (xulrunner) in the Mono Winforms WebControl"
HOMEPAGE="http://mono-project.com/Gluezilla"
SRC_URI="http://mono.ximian.com/monobuild/preview/sources/gluezilla/gluezilla-2.2.tar.bz2 -> ${P}.tar.bz2"

LICENSE="LGPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE=""

RDEPEND=">=dev-lang/mono-${PV}
	dev-libs/nss
	dev-libs/nspr
	>=net-libs/xulrunner-1.8.1.17"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P%_pre*}"

src_install () {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS ChangeLog README TODO || die "dodoc failed"
}
