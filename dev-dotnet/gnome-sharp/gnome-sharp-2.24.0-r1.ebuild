# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/gnome-sharp/gnome-sharp-2.24.0-r1.ebuild,v 1.1 2008/11/28 00:23:04 loki_val Exp $

EAPI=2

GTK_SHARP_MODULE_DEPS="art"
GTK_SHARP_REQUIRED_VERSION="2.12"

inherit gtk-sharp-module

SLOT="2"
KEYWORDS="~ppc ~sparc ~x86-fbsd ~x86 ~amd64"
IUSE=""

DEPEND=">=gnome-base/libgnomecanvas-2.20
	>=gnome-base/libgnomeui-2.24
	>=x11-libs/gtk+-2.12
	>=gnome-base/libgnomeprintui-2.18
	>=gnome-base/gnome-panel-2.24
	~dev-dotnet/gnomevfs-sharp-${PV}
	~dev-dotnet/art-sharp-${PV}"
