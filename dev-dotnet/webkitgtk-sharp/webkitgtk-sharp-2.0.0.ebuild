# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit mono-env autotools eutils

DESCRIPTION="C# bindings for WebKitGTK+ 3.0 using GObject Introspection"
HOMEPAGE="https://github.com/stsundermann/webkitgtk-sharp"
SRC_URI="https://github.com/stsundermann/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=dev-lang/mono-2.11
	>=dev-dotnet/gtk-sharp-2.99.2:3
	net-libs/webkit-gtk:3=
	dev-dotnet/soup-sharp"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	epatch "$FILESDIR/${P}-fadd308-libdir.patch"
	epatch "$FILESDIR/${P}-aaad3bf-mcs.patch"
	eautoreconf -I . -I m4
}

src_compile() {
	emake -j1
}
