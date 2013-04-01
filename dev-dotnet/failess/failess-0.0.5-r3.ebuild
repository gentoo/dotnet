# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

USE_DOTNET="net40"

inherit nuget mono

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
	doins Failess."${NPV}"/tools/Failess.exe || die
	doins Failess."${NPV}"/tools/Failess.exe.config
	doins Failess."${NPV}"/tools/FakeLib.dll || die
	doins Failess."${NPV}"/tools/FailessLib.dll || die
	doins Failess."${NPV}"/tools/FailLib.dll || die
	doins Failess."${NPV}"/tools/Newtonsoft.Json.dll
	doins Failess."${NPV}"/tools/NuGet.Core.dll
	doins Failess."${NPV}"/tools/Mono.Cecil.dll
}

pkg_postinst() {
	echo "mono /usr/lib/mono/Failess/${FRAMEWORK}/Failess.exe \"\$@\"" > /usr/bin/failess
	chmod 777 /usr/bin/failess
}
