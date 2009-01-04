# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/gnomevfs-sharp/gnomevfs-sharp-2.24.0-r1.ebuild,v 1.1 2008/11/28 00:23:28 loki_val Exp $

EAPI=2

GTK_SHARP_REQUIRED_VERSION="2.12"

inherit gtk-sharp-module

SLOT="2"
KEYWORDS="~x86 ~ppc ~sparc ~x86-fbsd ~amd64"
IUSE=""

RDEPEND=">=dev-dotnet/gtk-sharp-2.12.6[glade]
	>=gnome-base/gnome-vfs-2.24"
DEPEND="${RDEPEND}"
