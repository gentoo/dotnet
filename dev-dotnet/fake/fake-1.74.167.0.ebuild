# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#TODO: BUILD FROM TAG OR USE NUGET

EAPI=5

USE_DOTNET="net40"

inherit nuget mono

DESCRIPTION="FAKE - F# Make"
HOMEPAGE="http://nuget.org/packages/FAKE"
SRC_URI=""

LICENSE="MS-PL"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="dev-lang/mono
dev-lang/fsharp"
RDEPEND="${DEPEND}"

src_install() {
	elog "Installing libraries"
	insinto /usr/lib/mono/FAKE/"${FRAMEWORK}"/
	doins FAKE."${NPV}"/tools/FAKE.exe || die
	doins FAKE."${NPV}"/tools/FakeLib.dll || die
	doins FAKE."${NPV}"/tools/Newtonsoft.Json.dll
	doins FAKE."${NPV}"/tools/Fake.SQL.dll
}

pkg_postinst() {
	echo "mono /usr/lib/mono/FAKE/${FRAMEWORK}/FAKE.exe \"\$@\"" > /usr/bin/fake
	chmod 777 /usr/bin/fake
}
