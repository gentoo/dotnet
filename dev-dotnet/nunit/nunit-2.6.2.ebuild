# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
USE_DOTNET="net40"

inherit nuget mono

DESCRIPTION="unit-testing framework for all .Net languages"
HOMEPAGE="http://nunit.org"
SRC_URI=""

LICENSE="NUnit-License"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="!dev-lang/mono"
RDEPEND="${DEPEND}"

src_install() {
	elog "Installing libraries"
	insinto /usr/lib/mono/"${FRAMEWORK}"/
	doins NUnit."${NPV}"/lib/nunit.framework.dll || die
}

pkg_postinst() { :; }
