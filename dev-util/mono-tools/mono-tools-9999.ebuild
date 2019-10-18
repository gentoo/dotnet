# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit dotnet autotools git-r3

DESCRIPTION="Set of useful Mono related utilities"
HOMEPAGE="https://www.mono-project.com/"

EGIT_REPO_URI="git://github.com/mono/${PN}.git"

LICENSE="GPL-2 MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND=">=dev-dotnet/gtk-sharp-2.99
	dev-dotnet/webkit-sharp"
DEPEND="${RDEPEND}
	sys-devel/gettext
	virtual/pkgconfig"
PATCHES=(
	"${FILESDIR}/${PN}-2.8-html-renderer-fixes.patch"
)
MAKEOPTS="${MAKEOPTS} -j1" #nowarn

src_prepare() {
	default

	# Stop getting ACLOCAL_FLAGS command not found problem like bug #298813
	sed -i -e '/ACLOCAL_FLAGS/d' Makefile.am || die

	eautoreconf
}

src_configure() {
	econf --disable-dependency-tracking \
		--disable-gecko \
		--enable-webkit \
		--disable-gtkhtml \
		--disable-monowebbrowser || die
}
