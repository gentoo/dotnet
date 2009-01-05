# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/gtk-sharp/gtk-sharp-2.12.7.ebuild,v 1.2 2008/12/14 15:27:09 loki_val Exp $

EAPI="2"

inherit gtk-sharp-module

SLOT="2"
KEYWORDS="~amd64 ~ppc ~sparc ~x86 ~x86-fbsd"
IUSE="+glade"

RESTRICT="test"
