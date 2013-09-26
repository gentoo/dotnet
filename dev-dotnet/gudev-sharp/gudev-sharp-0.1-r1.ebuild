# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
inherit mono-env

DESCRIPTION="GUDEV API C# binding"
HOMEPAGE="http://launchpad.net/gudev-sharp"
SRC_URI="http://launchpad.net/${PN}/trunk/${PV}/+download/${PN}-1.0-${PV}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="dev-dotnet/gtk-sharp
	virtual/udev[gudev]"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S=${WORKDIR}/${PN}-1.0-${PV}

src_install() {
	emake DESTDIR="${D}" install
	dodoc AUTHORS
}
