# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/nautilusburn-sharp/nautilusburn-sharp-2.24.0-r1.ebuild,v 1.1 2008/11/28 00:24:39 loki_val Exp $

EAPI=2

GTK_SHARP_REQUIRED_VERSION="2.12"

inherit gtk-sharp-module

SLOT="2"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND="=dev-dotnet/gnome-sharp-${PV}*
	>=gnome-extra/nautilus-cd-burner-2.24"
DEPEND="${RDEPEND}"
