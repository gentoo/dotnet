# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
USE_DOTNET="net40"

inherit nuget dotnet eutils

DESCRIPTION=".NET Object Database"
HOMEPAGE="http://www.db4o.com/"
SRC_URI=""

LICENSE="GPL-1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="${DEPEND}"

src_install() {
	elog "Installing libraries"
	insinto /usr/lib/mono/"${FRAMEWORK}"/
	doins ${PN}.${PV}/lib/net40/*.dll
	doins ${PN}.${PV}/lib/net40/*.xml
}
