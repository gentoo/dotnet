# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit dotnet autotools git-r3

DESCRIPTION="monodoc stripped from mono-tools"
HOMEPAGE="https://www.mono-project.com/"

EGIT_REPO_URI="git://github.com/mono/mono-tools.git"

LICENSE="GPL-2 MIT"
SLOT="0"
KEYWORDS=""
IUSE="+webkit gtkhtml"

# gtkhtml is currently deprecated in Gentoo tree
RDEPEND=">=dev-dotnet/gtk-sharp-2.12.21:2
	>=dev-dotnet/gnome-sharp-2.24.2-r1
	gtkhtml? ( >=dev-dotnet/gnome-desktop-sharp-2.26.0-r2:2 )
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
