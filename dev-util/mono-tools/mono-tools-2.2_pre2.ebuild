# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/mono-tools/mono-tools-2.0.ebuild,v 1.4 2008/11/24 17:10:33 loki_val Exp $

EAPI=2

inherit base mono multilib eutils autotools

DESCRIPTION="Set of useful Mono related utilities"
HOMEPAGE="http://www.mono-project.com/"
SRC_URI="http://mono.ximian.com/monobuild/preview/sources/mono-tools/mono-tools-2.2.tar.bz2 -> ${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86 ~x86-fbsd"
IUSE="webkit xulrunner"

RDEPEND=">=dev-lang/mono-2.0
	>=dev-util/monodoc-${PV}
	>=dev-dotnet/gtk-sharp-2.12.6[glade]
	>=dev-dotnet/gconf-sharp-2
	>=dev-dotnet/gtkhtml-sharp-2
	webkit? ( dev-dotnet/webkit-sharp )
	xulrunner? ( >=dev-dotnet/gecko-sharp-0.13 )"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/pkgconfig-0.19"

PATCHES=( "${FILESDIR}/${PN}-2.0-html-renderer-fixes.patch" )

S=${WORKDIR}/${P%_pre1}

#Fails parallel make.
MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	base_src_prepare
	eautoreconf
}

src_configure() {
	econf --enable-gtkhtml $(use_enable xulrunner mozilla) $(use_enable webkit) || die "configure failed"
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc ChangeLog README
}
