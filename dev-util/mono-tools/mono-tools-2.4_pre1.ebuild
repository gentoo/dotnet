# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/mono-tools/mono-tools-2.2.ebuild,v 1.1 2009/01/18 17:46:30 loki_val Exp $

EAPI=2

inherit go-mono mono autotools

DESCRIPTION="Set of useful Mono related utilities"
HOMEPAGE="http://www.mono-project.com/"

LICENSE="GPL-2 MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="webkit xulrunner"

RDEPEND="=virtual/monodoc-${GO_MONO_REL_PV}*
	>=dev-dotnet/gtk-sharp-2.12.6
	>=dev-dotnet/glade-sharp-2.12.6
	>=dev-dotnet/gconf-sharp-2
	>=dev-dotnet/gtkhtml-sharp-2
	webkit? ( dev-dotnet/webkit-sharp )
	xulrunner? ( >=dev-dotnet/gecko-sharp-0.13 )"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/pkgconfig-0.19"

PATCHES=( "${FILESDIR}/${PN}-2.0-html-renderer-fixes.patch" )

#Fails parallel make.
MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	go-mono_src_prepare
	eautoreconf
}

src_configure() {
	econf	--disable-dependency-tracking \
		--enable-gtkhtml \
		$(use_enable xulrunner mozilla) \
		$(use_enable webkit) \
		|| die "configure failed"
}
