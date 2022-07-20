# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools mono-env

DESCRIPTION="C# bindings for WebKitGTK+ 3.0 using GObject Introspection"
HOMEPAGE="https://github.com/stsundermann/webkitgtk-sharp"
SRC_URI="https://github.com/stsundermann/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	>=dev-lang/mono-2.11
	>=dev-dotnet/gtk-sharp-2.99.2:3
	net-libs/webkit-gtk:3=
	dev-dotnet/soup-sharp"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${P}-fadd308-libdir.patch"
	"${FILESDIR}/${P}-aaad3bf-mcs.patch"
)

src_prepare() {
	default

	eautoreconf -I . -I m4
}

src_compile() {
	emake -j1
}
