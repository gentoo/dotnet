# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils dotnet flag-o-matic git-r3

DESCRIPTION="Library for using System.Drawing with mono"
HOMEPAGE="https://www.mono-project.com"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
EGIT_REPO_URI="https://github.com/mono/${PN}.git"

IUSE="cairo"

RDEPEND=">=dev-libs/glib-2.16:2
	>=media-libs/freetype-2.3.7
	>=media-libs/fontconfig-2.6
	>=media-libs/libpng-1.4:0
	x11-libs/libXrender
	x11-libs/libX11
	x11-libs/libXt
	>=x11-libs/cairo-1.8.4[X]
	media-libs/libexif
	>=media-libs/giflib-4.1.3
	virtual/jpeg:0
	media-libs/tiff:0
	!cairo? ( >=x11-libs/pango-1.20 )"
DEPEND="${RDEPEND}"

RESTRICT="test"

PATCHES=( "${FILESDIR}/${P}-giflib-quantizebuffer.patch"  )

src_prepare() {
	base_src_prepare
	NOCONFIGURE="true" ./autogen.sh
}

src_configure() {
	append-flags -fno-strict-aliasing
	econf 	--disable-dependency-tracking		\
		--disable-static			\
		$(use !cairo && printf %s --with-pango)
}

src_compile() {
	emake "$@"
}

src_install () {
	emake -j1 DESTDIR="${D}" "$@" install #nowarn
	dotnet_multilib_comply
	local commondoc=( AUTHORS ChangeLog README TODO )
	for docfile in "${commondoc[@]}"
	do
		[[ -e "${docfile}" ]] && dodoc "${docfile}"
	done
	if [[ "${DOCS[@]}" ]]
	then
		dodoc "${DOCS[@]}"
	fi
	prune_libtool_files
}
