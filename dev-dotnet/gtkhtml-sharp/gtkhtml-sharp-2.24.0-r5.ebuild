# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/gtkhtml-sharp/gtkhtml-sharp-2.24.0-r2.ebuild,v 1.1 2008/12/01 23:02:31 loki_val Exp $

EAPI=2

GTK_SHARP_REQUIRED_VERSION="2.12"

inherit gtk-sharp-module versionator

SLOT="2"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""

RESTRICT="test"
