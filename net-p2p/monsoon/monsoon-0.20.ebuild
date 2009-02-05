# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit mono multilib autotools

DESCRIPTION="Monosoon is an open source Gtk# bittorrent client"
HOMEPAGE="http://www.monsoon-project.org/"
SRC_URI="http://monotorrent.com/Files/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RDEPEND=">=dev-lang/mono-2.0.1
	>=dev-dotnet/monotorrent-0.70
	>=dev-dotnet/mono-nat-1.0
	>=dev-dotnet/nlog-1.0
	>=dev-dotnet/dbus-sharp-0.6.1a
	>=dev-dotnet/dbus-glib-sharp-0.4.1
	>=dev-dotnet/gtk-sharp-2.12.7-r10
	>=dev-dotnet/gdk-sharp-2.12.7-r10
	>=dev-dotnet/glib-sharp-2.12.7-r10
	>=dev-dotnet/gconf-sharp-2.24.0-r10"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.23"

#This sucks, but the install process is screwed up if it's set.
unset LINGUAS

src_prepare() {
	epatch "${FILESDIR}/${P}-build.patch"
	eautoreconf
}

src_compile() {
	emake -j1 ASSEMBLY_COMPILER_COMMAND="/usr/bin/gmcs"
}

src_install() {
	emake -j1 DESTDIR="${D}" install
	sed -i -e "s;@expanded_libdir@;/usr/$(get_libdir);" \
		"${D}/usr/bin/monsoon" || die "Fixing monsoon failed."
}
