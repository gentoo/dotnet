# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

USE_DOTNET="net40 net45"

inherit git-2 mono

EGIT_REPO_URI="git://github.com/Heather/Heather.git"

DESCRIPTION="F# Shell Scripting Library"
HOMEPAGE="https://github.com/Heather/Heather"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="fake"

DEPEND="dev-lang/mono"
RDEPEND="${DEPEND}"

src_compile() {
	if use fake; then
		if [[ -f /usr/lib/mono/Heather/"${FRAMEWORK}"/Heather.dll ]]; then
			fake
		else
			xbuild src/Heather.fsproj /p:Configuration=Release
		fi
	else
		xbuild src/Heather.fsproj /p:Configuration=Release
	fi
}

src_install() {
	insinto /usr/lib/mono/Heather/"${FRAMEWORK}"
	doins src/bin/Release/Heather.dll
}
