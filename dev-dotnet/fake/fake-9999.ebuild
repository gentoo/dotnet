# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
USE_DOTNET="net40"

inherit git-2 eutils dotnet

DESCRIPTION="FAKE - F# Make"
HOMEPAGE="https://github.com/fsharp/FAKE"
SRC_URI=""

LICENSE="MS-PL"
SLOT="0"
KEYWORDS=""
IUSE="heather"

if use heather; then
	EGIT_REPO_URI="git://github.com/Heather/FAKE.git"
	EGIT_MASTER="develop"
else
	EGIT_REPO_URI="git://github.com/fsharp/FAKE.git"
	EGIT_MASTER="develop"
fi

DEPEND="dev-lang/mono
dev-lang/fsharp"
RDEPEND="${DEPEND}"

src_prepare() {
	addpredict /etc/mono/registry/last-btime #nowarn
}

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
	doins build/UnionArgParser.dll
	nonfatal doins tools/FAKE/tools/Newtonsoft.Json.dll
	nonfatal doins tools/FAKE/tools/Fake.SQL.dll
	nonfatal doins tools/FAKE/tools/NuGet.Core.dll
	make_wrapper fake "mono /usr/lib/mono/FAKE/${FRAMEWORK}/FAKE.exe"
}
