# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

USE_DOTNET="net40"

inherit autotools dotnet

DESCRIPTION="The F# Compiler"
HOMEPAGE="https://github.com/fsharp/fsharp"
SRC_URI="https://github.com/fsharp/fsharp/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

MAKEOPTS="-j1" #nowarn
DEPEND="|| ( >dev-lang/mono-3.0.6 <dev-lang/mono-3.0.5 )"
RDEPEND="${DEPEND}"

src_prepare() {
	eautoreconf
}

src_install() {
	default
	dosym /usr/bin/fsharpc /usr/bin/fsc
}
