# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit dotnet versionator

DESCRIPTION="Library used to make awesome applications."
HOMEPAGE="http://live.gnome.org/Hyena"
SRC_URI="mirror://gnome/sources/${PN}/$(get_version_component_range 1-2)/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug"

RDEPEND=">=dev-lang/mono-2.4.2
	dev-dotnet/glib-sharp
	dev-dotnet/gtk-sharp"
DEPEND="${RDEPEND}
	sys-apps/sed
	virtual/pkgconfig"

src_configure() {
	sed -i 's/dnl/#/' */Makefile.in || die "sed failed" # to make it work with make 3.82
	econf --enable-$(usex debug debug release)
}
