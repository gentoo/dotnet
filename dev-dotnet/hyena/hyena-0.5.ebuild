# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit dotnet versionator

DESCRIPTION="Library used to make awesome applications."
HOMEPAGE="https://live.gnome.org/Hyena"
SRC_URI="mirror://gnome/sources/${PN}/$(get_version_component_range 1-2)/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

RDEPEND=">=dev-lang/mono-2.4.2
	dev-dotnet/glib-sharp
	dev-dotnet/gtk-sharp:2"
DEPEND="${RDEPEND}
	sys-apps/sed
	virtual/pkgconfig"

src_configure() {
	sed -i 's/dnl/#/' */Makefile.in || die "sed failed" # to make it work with make 3.82
	econf --enable-$(usex debug debug release)
}
