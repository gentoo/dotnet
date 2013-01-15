# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

EGIT_REPO_URI="git://github.com/Cynede/FChess.git"

inherit git-2 fake

DESCRIPTION="FAKE - F# Make"
HOMEPAGE="https://github.com/Cynede/FChess"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="dev-lang/mono"
RDEPEND="${DEPEND}"

src_install() {
	insinto /usr/lib/mono/4.0
	doins src/bin/Release/FChess.exe
}

pkg_postinst() {
	echo "mono /usr/lib/mono/4.0/FChess.exe" > /usr/bin/fchess
	chmod 777 /usr/bin/fchess
}
