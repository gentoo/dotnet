# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils mono-env multilib

DESCRIPTION="A generic framework for creating extensible applications"
HOMEPAGE="https://www.mono-project.com/Mono.Addins"
SRC_URI="https://download.mono-project.com/sources/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="+gtk"

RDEPEND=">=dev-lang/mono-2
	gtk? (  >=dev-dotnet/gtk-sharp-2.0:2 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare()
{
	epatch "${FILESDIR}/gmcs.patch"
	# eautoreconf 
	## fails with the message "./mautil/Makefile.am:40: error: 'pkglibdir' is not a legitimate directory for 'SCRIPTS'"
	# "${S}/autogen.sh" || die
	## file doesn't exist
}

src_configure() {
	econf $(use_enable gtk gui)
}

src_compile() {
	emake -j1 #nowarn
}

src_install() {
	emake -j1 DESTDIR="${D}" install #nowarn
	mono_multilib_comply
}
