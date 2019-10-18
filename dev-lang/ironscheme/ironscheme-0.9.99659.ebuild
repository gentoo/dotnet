# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

USE_DOTNET="net40"

inherit dotnet multilib

DESCRIPTION="R6RS conforming Scheme-like implementation based on the Microsoft DLR"
HOMEPAGE="https://ironscheme.codeplex.com/"
SRC_URI=""

LICENSE="Ms-PL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	elog "Installing libraries"
	insinto /usr/lib/mono/IronScheme/"${FRAMEWORK}"/
	doins IronScheme."${NPV}"/lib/*
}
