# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

USE_DOTNET="net40 net45"

inherit git-2 fake mono

EGIT_REPO_URI="git://github.com/Cynede/FChess.git"

DESCRIPTION="FAKE - F# Make"
HOMEPAGE="https://github.com/Cynede/FChess"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="dev-lang/mono
dev-dotnet/heather"
RDEPEND="${DEPEND}"

src_install() {
	insinto /usr/lib/mono/"${FRAMEWORK}"
	doins src/bin/Release/FChess.exe
}

pkg_postinst() {
	echo "mono /usr/lib/mono/${FRAMEWORK}/FChess.exe" > /usr/bin/fchess
	chmod 777 /usr/bin/fchess
}
