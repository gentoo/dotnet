# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit mono

if ! [[ "${PV%_rc*}" = "${PV}" ]]
then
	MY_P=${P%_rc*}
elif ! [[ "${PV%_pre*}" = "${PV}" ]]
then
	 MY_P=${P%_pre*}
else
	MY_P=${P}
fi

DESCRIPTION="A simple library to embed Gecko (xulrunner) in the Mono Winforms WebControl"
HOMEPAGE="http://mono-project.com/Gluezilla"
SRC_URI="http://mono.ximian.com/monobuild/preview/sources/gluezilla/${MY_P} -> ${P}.tar.bz2"

LICENSE="LGPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE=""

RDEPEND=">=dev-lang/mono-${PV}
	net-libs/xulrunner:1.9
	x11-libs/gtk+:2"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_install () {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS ChangeLog README TODO || die "dodoc failed"
}
