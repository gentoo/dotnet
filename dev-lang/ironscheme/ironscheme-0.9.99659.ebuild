# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

USE_DOTNET="net40"

inherit dotnet multilib

DESCRIPTION="R6RS conforming Scheme-like implementation based on the Microsoft DLR"
HOMEPAGE="http://ironscheme.codeplex.com/"
SRC_URI=""

LICENSE="Ms-PL"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	elog "Installing libraries"
	insinto /usr/lib/mono/IronScheme/"${FRAMEWORK}"/
	doins IronScheme."${NPV}"/lib/*
}
