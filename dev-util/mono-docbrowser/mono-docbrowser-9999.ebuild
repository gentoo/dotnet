# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/mono-tools/mono-tools-9999.ebuild $

EAPI=5

inherit base dotnet autotools git-2

DESCRIPTION="monodoc stripped from mono-tools"
HOMEPAGE="http://www.mono-project.com/"

EGIT_REPO_URI="git://github.com/mono/mono-tools.git"

LICENSE="GPL-2 MIT"
SLOT="0"
KEYWORDS=""
IUSE="+webkit gtkhtml"

RDEPEND="virtual/monodoc
	>=dev-dotnet/gtk-sharp-2.12.21
	>=dev-dotnet/gnome-sharp-2.24.2-r1
	gtkhtml? ( >=dev-dotnet/gnome-desktop-sharp-2.26.0-r2:2[gtkhtml] )
	webkit? ( >=dev-dotnet/webkit-sharp-0.2-r1 )"
DEPEND="${RDEPEND}
	sys-devel/gettext
	virtual/pkgconfig"

PATCHES=( "${FILESDIR}/mono-tools-2.8-html-renderer-fixes.patch"
	"${FILESDIR}/mono-tools-docbrowser-basedir-fix.patch" )
MAKEOPTS="${MAKEOPTS} -j1" #nowarn

pkg_setup() {
	if ! use webkit && ! use gtkhtml
	then
		die "You must USE either webkit or gtkhtml"
	fi
}

src_prepare() {
	base_src_prepare

	# Stop getting ACLOCAL_FLAGS command not found problem like bug #298813
	sed -i -e '/ACLOCAL_FLAGS/d' Makefile.am || die

	eautoreconf
}

src_configure() {
	econf	--disable-dependency-tracking \
		--disable-gecko \
		$(use_enable gtkhtml) \
		$(use_enable webkit) \
		--disable-monowebbrowser || die
}

src_compile() {
	cd docbrowser
	default
}

src_install() {
	cd docbrowser
	default
}
