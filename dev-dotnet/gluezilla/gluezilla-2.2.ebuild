# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit go-mono mono

DESCRIPTION="A simple library to embed Gecko (xulrunner) in the Mono Winforms WebControl"
HOMEPAGE="http://mono-project.com/Gluezilla"

LICENSE="LGPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE=""

RDEPEND="net-libs/xulrunner:1.9
	x11-libs/gtk+:2"
RDEPEND="${DEPEND}"
