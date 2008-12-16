# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/mono-basic/mono-basic-2.0.ebuild,v 1.2 2008/11/23 19:57:28 loki_val Exp $

EAPI=2

inherit mono multilib

DESCRIPTION="Visual Basic .NET Runtime and Class Libraries"
HOMEPAGE="http://www.go-mono.com"
SRC_URI="http://mono.ximian.com/monobuild/preview/sources/mono-basic/${P%_pre*}.tar.bz2 -> ${P}.tar.bz2"

LICENSE="|| ( GPL-2 LGPL-2 X11 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="=dev-lang/mono-${PV}*"
DEPEND="${RDEPEND}"

RESTRICT="test"

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
}
