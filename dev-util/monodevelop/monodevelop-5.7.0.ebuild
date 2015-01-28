# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
inherit fdo-mime gnome2-utils dotnet versionator eutils git-r3

DESCRIPTION="Integrated Development Environment for .NET"
HOMEPAGE="http://www.monodevelop.com/"
SRC_URI="http://download.mono-project.com/sources/${PN}/${P}.660.tar.bz2
	https://launchpadlibrarian.net/153448659/NUnit-2.6.3.zip
	https://launchpadlibrarian.net/68057829/NUnit-2.5.10.11092.zip"

EGIT_REPO_URI="https://github.com/mono/nuget-binary.git"
EGIT_CHECKOUT_DIR=${WORKDIR}/NuGet

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+subversion +git doc"

RDEPEND=">=dev-lang/mono-3.2.8
	>=dev-dotnet/gnome-sharp-2.24.2-r1
	>=dev-dotnet/gtk-sharp-2.12.21
	>=dev-dotnet/mono-addins-1.0[gtk]
	doc? ( dev-util/mono-docbrowser )
	>=dev-dotnet/xsp-2
	dev-util/ctags
	sys-apps/dbus[X]
	subversion? ( dev-vcs/subversion )
	!<dev-util/monodevelop-boo-$(get_version_component_range 1-2)
	!<dev-util/monodevelop-java-$(get_version_component_range 1-2)
	!<dev-util/monodevelop-database-$(get_version_component_range 1-2)
	!<dev-util/monodevelop-debugger-gdb-$(get_version_component_range 1-2)
	!<dev-util/monodevelop-debugger-mdb-$(get_version_component_range 1-2)
	!<dev-util/monodevelop-vala-$(get_version_component_range 1-2)"
DEPEND="${RDEPEND}
	dev-util/intltool
	virtual/pkgconfig
	sys-devel/gettext
	x11-misc/shared-mime-info
	x11-terms/xterm
	app-arch/unzip"
MAKEOPTS="${MAKEOPTS} -j1" #nowarn
S="${WORKDIR}/monodevelop-5.7"

src_unpack() {
	#unpack all archives
	unpack ${A}

	#clone NuGet binaries
	git-r3_fetch
	git-r3_checkout
}

src_prepare() {
	# Remove the git rev-parse (changelog?)
	sed -i '/<Exec.*rev-parse/ d' "${S}/src/core/MonoDevelop.Core/MonoDevelop.Core.csproj" || die
	# Set specific_version to prevent binding problem
	# when gtk#-3 is installed alongside gtk#-2
	find "${S}" -name '*.csproj' -exec sed -i 's#<SpecificVersion>.*</SpecificVersion>#<SpecificVersion>True</SpecificVersion>#' {} + || die

	#copy missing binaries
	mkdir -p "${S}/packages/NUnit.2.6.3/lib" || die
	mkdir -p "${S}/packages/NUnit.Runners.2.6.3/tools/lib" || die
	cp -fR "${WORKDIR}"/NUnit-2.6.3/bin/framework/* "${S}"/packages/NUnit.2.6.3/lib
	cp -fR "${WORKDIR}"/NUnit-2.6.3/bin/lib/* "${S}"/packages/NUnit.Runners.2.6.3/tools/lib/ || die
	cp -fR "${WORKDIR}"/NUnit-2.5.10.11092/bin/net-2.0/framework/* "${S}"/external/cecil/Test/libs/nunit-2.5.10/ || die
	cp -fR "${WORKDIR}"/NuGet/* "${S}"/external/nuget-binary/ || die
}

src_configure() {
	econf \
		--disable-update-mimedb \
		--disable-update-desktopdb \
		--enable-monoextensions \
		--enable-gnomeplatform \
		$(use_enable subversion) \
		$(use_enable git)
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update
}
