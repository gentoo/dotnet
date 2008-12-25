# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/mono-tools/mono-tools-2.0.ebuild,v 1.4 2008/11/24 17:10:33 loki_val Exp $

EAPI=2

inherit go-mono mono base multilib eutils autotools

DESCRIPTION="Set of useful Mono related utilities"
HOMEPAGE="http://www.mono-project.com/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86 ~x86-fbsd"
IUSE="webkit xulrunner"

RDEPEND="=dev-lang/mono-${PV}*
	=virtual/monodoc-${PV}
	>=dev-dotnet/gtk-sharp-2.12.6[glade]
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
	go-mono_src_configure	--enable-gtkhtml \
				$(use_enable xulrunner mozilla) \
				$(use_enable webkit) \
				|| die "configure failed"
}
