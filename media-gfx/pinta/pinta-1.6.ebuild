# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit autotools fdo-mime gnome2-utils mono-env

DESCRIPTION="Simple Painting for Gtk"
HOMEPAGE="https://pinta-project.com"
SRC_URI="https://github.com/PintaProject/Pinta/archive/${PV}.tar.gz"

LICENSE="MIT CC-BY-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

COMMON_DEPEND=">=dev-lang/mono-4.0.2
	>=dev-dotnet/gtk-sharp-2.12.21:2
	>=dev-dotnet/mono-addins-1.0-r1[gtk]
	"

RDEPEND="${COMMON_DEPEND}
	x11-libs/cairo[X]
	x11-libs/gdk-pixbuf[X,jpeg,tiff]
	x11-themes/gnome-icon-theme"
DEPEND="${COMMON_DEPEND}
	dev-util/intltool
	virtual/pkgconfig"

S=${WORKDIR}/Pinta-${PV}

src_prepare() {
	local i
	if [[ -n "${LINGUAS+x}" ]] ; then
		for i in $(cd "${S}"/po ; echo *.po) ; do
			if ! has ${i%.po} ${LINGUAS} ; then
				sed -i -e "/po\/${i%.po}.po/{N;N;d;}" Pinta.Install.proj || die
			fi
		done
	fi

	eautoreconf

	oldstring=Version=2.0.0.0
	newstring=Version=4.0.0.0
	einfo "updating '$oldstring'->'$newstring'"
	find "${S}" -iname "*.csproj" -print | xargs sed -i "s@${oldstring}@${newstring}@g" || die

	oldstring='ToolsVersion="3.5"'
	newstring='ToolsVersion="4.0"'
	einfo "updating '$oldstring'->'$newstring'"
	find "${S}" -iname "*.proj" -print | xargs sed -i "s@${oldstring}@${newstring}@g" || die
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}
