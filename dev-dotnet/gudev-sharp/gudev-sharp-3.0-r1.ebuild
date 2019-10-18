# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit mono-env

DESCRIPTION="GUDEV API C# binding"
HOMEPAGE="https://github.com/mono/gudev-sharp"
SRC_URI="https://github.com/mono/${PN}/releases/download/3.0.0/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

#gudev is not the flag of udev anymore
RDEPEND="dev-dotnet/gtk-sharp:3
	virtual/udev
	virtual/libgudev"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_install() {
	emake DESTDIR="${D}" install
	dodoc AUTHORS
}
