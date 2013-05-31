# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

USE_DOTNET="net45 net40"

inherit nuget dotnet

DESCRIPTION="FAKE - F# Make"
HOMEPAGE="http://nuget.org/packages/FAKE"
SRC_URI=""

LICENSE="MS-PL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-lang/mono
dev-lang/fsharp"
RDEPEND="${DEPEND}"

#TODO: better installation
src_install() {
	elog "Installing libraries"
	insinto /usr/lib/mono/WebSharper/"${FRAMEWORK}"/
	doins WebSharper."${NPV}"/*.dll || die
	doins WebSharper."${NPV}"/*.exe || die
}

pkg_postinst() {
	echo "mono /usr/lib/mono/WebSharper/${FRAMEWORK}/WebSharper.v${FRAMEWORK}.exe \"$@\"" > /usr/bin/websharper
	chmod 777 /usr/bin/websharper
}
