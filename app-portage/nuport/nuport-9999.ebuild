# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

USE_DOTNET="net40 net45"

inherit git-2 fake mono

EGIT_REPO_URI="git://github.com/Heather/nuport.git"

DESCRIPTION="F# NuGet to Portage converter"
HOMEPAGE="https://github.com/gentoo-dotnet/nuport.git"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="dev-lang/mono
dev-dotnet/shelly"
RDEPEND="${DEPEND}"

src_install() {
	insinto /usr/lib/mono/nuport/"${FRAMEWORK}"
	doins src/bin/Release/FSharp.Core.dll
	doins src/bin/Release/shelly.dll
	doins src/bin/Release/NuGet.Core.dll
	doins src/bin/Release/nuport.exe
}

pkg_postinst() {
	echo "mono /usr/lib/mono/nuport/${FRAMEWORK}/nuport.exe  \"\$@\"" > /usr/bin/nuport
	chmod 777 /usr/bin/nuport
}
