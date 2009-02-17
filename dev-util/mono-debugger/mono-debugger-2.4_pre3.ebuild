# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/mono-debugger/mono-debugger-2.2.ebuild,v 1.2 2009/01/19 21:33:55 loki_val Exp $

EAPI=2

inherit go-mono mono

DESCRIPTION="Debugger for .NET managed and unmanaged applications"
HOMEPAGE="http://www.go-mono.com"

LICENSE="GPL-2 MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND="!!=dev-lang/mono-2.2
	sys-libs/readline
	dev-libs/glib:2"
DEPEND="${RDEPEND}
	!dev-lang/mercury"

RESTRICT="test"
