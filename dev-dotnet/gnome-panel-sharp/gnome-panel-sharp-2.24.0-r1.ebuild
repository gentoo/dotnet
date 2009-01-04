# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/gnome-panel-sharp/gnome-panel-sharp-2.24.0-r1.ebuild,v 1.1 2008/11/28 00:22:17 loki_val Exp $

EAPI=2

GTK_SHARP_REQUIRED_VERSION="2.12"
GTK_SHARP_MODULE_DIR="gnomepanel"

inherit gtk-sharp-module

SLOT="2"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND="=dev-dotnet/gnome-sharp-${PV}*
	x11-libs/libwnck"
DEPEND="${RDEPEND}"
