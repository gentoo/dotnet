# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
USE_DOTNET="net40"

inherit git-2 eutils dotnet

EGIT_REPO_URI="git://github.com/Heather/FAKE.git"
EGIT_MASTER="develop"

DESCRIPTION="FAKE - F# Make"
HOMEPAGE="https://github.com/fsharp/FAKE"
SRC_URI=""

LICENSE="MS-PL"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="dev-lang/mono
dev-lang/fsharp"
RDEPEND="${DEPEND}"

src_compile() {
	ln -s tools/FAKE/tools/Newtonsoft.Json.dll "${S}"/Newtonsoft.Json.dll || die
	ln -s tools/FAKE/tools/NuGet.Core.dll "${S}"/NuGet.Core.dll || die
	ln -s tools/FAKE/tools/Fake.SQL.dll "${S}"/Fake.SQL.dll || die
	./build.sh || die "build.sh failed"
}

src_install() {
	elog "Installing libraries"
	insinto /usr/lib/mono/FAKE/"${FRAMEWORK}"/
	doins build/FAKE.exe
	doins build/FakeLib.dll
	make_wrapper fake "mono /usr/lib/mono/FAKE/${FRAMEWORK}/FAKE.exe \"\$@\""
}
