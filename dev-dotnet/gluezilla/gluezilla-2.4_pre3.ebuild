# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/gluezilla/gluezilla-2.2.ebuild,v 1.2 2009/01/19 13:33:33 loki_val Exp $

EAPI=2

inherit go-mono mono

DESCRIPTION="A simple library to embed Gecko (xulrunner) in the Mono Winforms WebControl"
HOMEPAGE="http://mono-project.com/Gluezilla"

LICENSE="LGPL-2 MPL-1.1"
KEYWORDS="~x86 ~amd64"
SLOT="0"
IUSE=""

RDEPEND="net-libs/xulrunner:1.9
	x11-libs/gtk+:2"
DEPEND="${RDEPEND}"
