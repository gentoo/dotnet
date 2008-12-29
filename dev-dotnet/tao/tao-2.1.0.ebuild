# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils autotools mono
MY_PN=${PN}framework
MY_P=${MY_PN}-${PV}

DESCRIPTION="The Tao .NET/C# framework for OpenGL"
HOMEPAGE="http://www.taoframework.com/"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_P}.tar.gz"
LICENSE="MIT"
SLOT="0"

KEYWORDS="~x86"

IUSE=""

RDEPEND=">=dev-lang/mono-2.0
	virtual/monodoc"
DEPEND="${DEPEND}
	>=dev-util/pkgconfig-0.23"

#MAKEOPTS="${MAKEOPTS} -j1"

S="${WORKDIR}/${MY_P}/source"

src_prepare() {
	epatch "${FILESDIR}/${P}-monodoc.patch"
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO || die "dodoc failed"
}
