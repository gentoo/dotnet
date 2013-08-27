# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit base dotnet autotools flag-o-matic eutils git-2

DESCRIPTION="Debugger for .NET managed and unmanaged applications"
HOMEPAGE="http://www.mono-project.com/"

EGIT_REPO_URI="git://github.com/mono/debugger.git"

LICENSE="GPL-2 MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RESTRICT="test"

# Binutils is needed for libbfd
RDEPEND="!!=dev-lang/mono-2.2
	sys-devel/binutils
	dev-libs/glib:2"
DEPEND="${RDEPEND}
	!dev-lang/mercury"

src_prepare() {
	base_src_prepare

	# Allow compilation against system libbfd, bnc#662581
	epatch "${FILESDIR}/${PN}-2.8-system-bfd.patch"
	eautoreconf
}

src_configure() {
	append-ldflags -Wl,--no-undefined #nowarn
	econf 	--disable-dependency-tracking		\
		--disable-static			\
		--with-system-libbfd 		\
		--disable-static
}

src_compile() {
	emake -j1 #nowarn
}
