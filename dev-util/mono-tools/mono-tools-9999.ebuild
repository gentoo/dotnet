# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit dotnet autotools git-r3

DESCRIPTION="Set of useful Mono related utilities"
HOMEPAGE="http://www.mono-project.com/"

EGIT_REPO_URI="git://github.com/mono/${PN}.git"

LICENSE="GPL-2 MIT"
SLOT="0"
KEYWORDS=""
IUSE="+webkit"

RDEPEND=">=dev-dotnet/gtk-sharp-2.99
	webkit? ( dev-dotnet/webkit-sharp )"
DEPEND="${RDEPEND}
	sys-devel/gettext
	virtual/pkgconfig"
PATCHES=(
	"${FILESDIR}/${PN}-2.8-html-renderer-fixes.patch"
	"${FILESDIR}/${P}_make_build_use_2_0.patch"
)
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
		$(use_enable webkit) \
		--disable-monowebbrowser || die
}
