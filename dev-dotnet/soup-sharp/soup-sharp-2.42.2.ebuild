# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit mono-env autotools eutils

DESCRIPTION="C# Bindings for libsoup2.4"
HOMEPAGE="https://github.com/stsundermann/soup-sharp"
SRC_URI="https://github.com/stsundermann/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=dev-lang/mono-2.11
	>=dev-dotnet/gtk-sharp-2.99.2:3
	net-libs/libsoup"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	mkdir -p doc/en # upstream d474abc
	epatch "$FILESDIR/${P}-4404312-libdir.patch"
	epatch "$FILESDIR/${P}-5898dab-mcs.patch"
	eautoreconf -I . -I m4
}

src_compile() {
	emake -j1
}
