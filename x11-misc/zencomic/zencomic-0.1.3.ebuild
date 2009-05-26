# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit mono

DESCRIPTION="Displays random comics in notification balloons."
HOMEPAGE="http://netherilshade.free.fr/mono/"

SRC_URI="http://netherilshade.free.fr/mono/${P}.tar.gz"

LICENSE="MIT"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

RDEPEND=">=dev-dotnet/mono-addins-0.4
	dev-dotnet/glib-sharp
	dev-dotnet/gtk-sharp
	dev-dotnet/dbus-sharp
	dev-dotnet/dbus-glib-sharp"
DEPEND="${RDEPEND}"

MAKEOPTS=-j1

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
