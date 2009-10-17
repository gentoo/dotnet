# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/monodevelop-database/monodevelop-database-2.0.ebuild,v 1.1 2009/03/30 18:57:26 loki_val Exp $

EAPI=2

inherit mono multilib

DESCRIPTION="Database Browser Extension for MonoDevelop"
HOMEPAGE="http://www.monodevelop.com/"
SRC_URI="http://ftp.novell.com/pub/mono/sources/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-lang/mono-2.4
	=dev-util/monodevelop-${PV}*
	dev-dotnet/gtksourceview-sharp:1"

DEPEND="${RDEPEND}
	x11-misc/shared-mime-info
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.19"

src_compile() {
	emake -j1 || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc ChangeLog README || die "dodoc failed"
	mono_multilib_comply
}
