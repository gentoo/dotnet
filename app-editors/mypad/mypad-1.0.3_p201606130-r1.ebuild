# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

KEYWORDS="~amd64"
RESTRICT="mirror"

SLOT="1"
IUSE="net45 debug developer"
USE_DOTNET="net45"

inherit eutils gnome2-utils dotnet

DESCRIPTION="mypad text editor"
LICENSE="MIT"

PROJECTNAME="mypad-winforms-texteditor"
HOMEPAGE="https://github.com/ArsenShnurkov/${PROJECTNAME}"
EGIT_COMMIT="c1c79094eb5339309e3767f64d4e87f6214e7faa"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${PROJECTNAME}-${EGIT_COMMIT}"

CDEPEND="|| ( >=dev-lang/mono-4 <dev-lang/mono-9999 )
	|| ( dev-dotnet/icsharpcodetexteditor[gac] )
	|| ( dev-dotnet/ndepend-path[gac] )
	"

# The DEPEND ebuild variable should specify any dependencies which are 
# required to unpack, patch, compile or install the package
DEPEND="${CDEPEND}
	dev-dotnet/nuget
	"

# The RDEPEND ebuild variable should specify any dependencies which are 
# required at runtime. 
# when installing from a binary package, only RDEPEND will be checked.
RDEPEND="${CDEPEND}
	"

# METAFILETOBUILD=${PROJECTNAME}.sln
METAFILETOBUILD=MyPad.sln

pkg_preinst() {
	gnome2_icon_savelist
}

src_prepare() {
	eapply "${FILESDIR}/0001-.csproj-dependency-.nupkg-dependency.patch"
	eapply "${FILESDIR}/0001-remove-project-from-solution.patch"
	find "${S}" -iname "*.cs" -exec sed -i "s/using NDepend.Path.Interface.Core;//g" {} \; || die
	#elog "NuGet restore"
	#addwrite "/usr/share/.mono/keypairs"
	#/usr/bin/nuget restore ${METAFILETOBUILD} || die
	eapply_user
}

src_compile() {
	# https://bugzilla.xamarin.com/show_bug.cgi?id=9340
	exbuild ${METAFILETOBUILD}
}

src_install() {
	local BINDIR=""
	if use debug; then
		BINDIR=MyPad/bin/Debug
	else
		BINDIR=MyPad/bin/Release
	fi

	elog "Installing executable"
	insinto /usr/lib/mypad-${PV}/
	newins "${BINDIR}/MyPad.exe" MyPad.exe
	make_wrapper mypad "mono /usr/lib/mypad-${PV}/MyPad.exe"

	elog "Installing syntax coloring schemes for editor"
	dodir /usr/lib/mypad-${PV}/Modes
	insinto /usr/lib/mypad-${PV}/Modes
	doins $BINDIR/Modes/*.xshd

	elog "Preparing data directory"
	# actually this should be in the user home folder
	dodir /usr/lib/mypad-${PV}/Data

	elog "Configuring templating engine"
	# actually this should be in the user home folder
	dosym /usr/lib/mypad-${PV} /usr/lib/mypad-${PV}/bin
	insinto /usr/lib/mypad-${PV}
	doins $BINDIR/*.aspx
	doins $BINDIR/*.config

	elog "Installing desktop icon"
	local ICON_NAME=AtomFeedIcon.svg
	local FULL_ICON_NAME=MyPad/Resources/${ICON_NAME}
	newicon -s scalable "${FULL_ICON_NAME}" "${ICON_NAME}"
	make_desktop_entry "/usr/bin/mypad" "${DESCRIPTION}" "/usr/share/icons/hicolor/scalable/apps/${ICON_NAME}"
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
