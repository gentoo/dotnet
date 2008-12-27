# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/tomboy/tomboy-0.12.1.ebuild,v 1.7 2008/12/10 16:01:37 loki_val Exp $

EAPI=2

inherit eutils gnome2 mono

DESCRIPTION="Desktop note-taking application"
HOMEPAGE="http://www.beatniksoftware.com/tomboy/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc eds galago"

RDEPEND=">=dev-lang/mono-2
		 >=dev-dotnet/gtk-sharp-2.12.6-r1
		 >=dev-dotnet/gconf-sharp-2.24.0
		 >=dev-dotnet/gnome-sharp-2.24.0
		 >=dev-dotnet/gnome-panel-sharp-2.24.0
		 >=dev-dotnet/gnome-desktop-sharp-2.16.1
		 >=dev-dotnet/dbus-sharp-0.4
		 >=dev-dotnet/dbus-glib-sharp-0.3
		 >=dev-dotnet/mono-addins-0.3
		 >=x11-libs/gtk+-2.12.0
		 >=dev-libs/atk-1.2.4
		 >=gnome-base/gconf-2
		 >=app-text/gtkspell-2.0.9
		 >=gnome-base/gnome-panel-2.24.0
		 eds? ( dev-libs/gmime:2.4[mono] )
		 galago? ( =dev-dotnet/galago-sharp-0.5* )
		 >=gnome-base/libgnomeprintui-2.18.3
		 >=gnome-base/libgnomeprint-2.2"
DEPEND="${RDEPEND}
		  app-text/gnome-doc-utils
		  dev-libs/libxml2[python]
		  sys-devel/gettext
		  dev-util/pkgconfig
		>=dev-util/intltool-0.35"

DOCS="AUTHORS ChangeLog INSTALL NEWS README"

src_prepare() {
	sed -i -e 's:gmime-sharp:gmime-sharp-2.4:g' configure || die "sed failed"
}

src_configure() {
	G2CONF="${G2CONF} $(use_enable galago) $(use_enable eds evolution) --with-mono-addins=system"
	gnome2_src_configure
}

src_compile() {
	default
}
