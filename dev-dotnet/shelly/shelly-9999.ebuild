# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
USE_DOTNET="net40 net45"

inherit git-2 dotnet

EGIT_REPO_URI="git://github.com/Heather/shelly.git"

DESCRIPTION="F# Shell Scripting Library"
HOMEPAGE="https://github.com/Heather/shelly"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="dev-lang/mono"
RDEPEND="${DEPEND}"

src_compile() {
	xbuild src/shelly.fsproj /p:Configuration=Release
}

src_install() {
	insinto /usr/lib/mono/shelly/"${FRAMEWORK}"
	doins src/bin/Release/shelly.dll
}
