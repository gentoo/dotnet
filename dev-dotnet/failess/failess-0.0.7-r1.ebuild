# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

USE_DOTNET="net40"

inherit nuget dotnet eutils

DESCRIPTION="Failess"
HOMEPAGE="http://nuget.org/packages/Failess"
SRC_URI=""

LICENSE="MS-PL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-lang/mono
dev-lang/fsharp"
RDEPEND="${DEPEND}"

src_install() {
	elog "Installing libraries"
	insinto /usr/lib/mono/Failess/"${FRAMEWORK}"/
	doins Failess."${NPV}"/tools/Failess.exe
	doins Failess."${NPV}"/tools/Failess.exe.config
	doins Failess."${NPV}"/tools/FakeLib.dll
	doins Failess."${NPV}"/tools/FailessLib.dll
	doins Failess."${NPV}"/tools/FailLib.dll
	doins Failess."${NPV}"/tools/Newtonsoft.Json.dll
	doins Failess."${NPV}"/tools/NuGet.Core.dll
	doins Failess."${NPV}"/tools/Mono.Cecil.dll
	make_wrapper failess "mono /usr/lib/mono/Failess/${FRAMEWORK}/Failess.exe \"\$@\""
}
