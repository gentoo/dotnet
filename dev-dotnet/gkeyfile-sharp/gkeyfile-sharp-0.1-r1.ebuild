# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit autotools dotnet

DESCRIPTION="C# binding for gkeyfile"
HOMEPAGE="https://launchpad.net/gkeyfile-sharp https://github.com/mono/gkeyfile-sharp"
SRC_URI="https://github.com/mono/${PN}/tarball/GKEYFILE_SHARP_0_1 -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-dotnet/gtk-sharp-2.12.21:2"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_unpack() {
	unpack ${A}
	mv *-${PN}-* "${S}"
}

src_prepare() {
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc AUTHORS ChangeLog NEWS
}
