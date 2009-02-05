# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit mono multilib

DESCRIPTION="Monotorrent is an open source C# bittorrent library"
HOMEPAGE="http://www.monotorrent.com/"
SRC_URI="http://monotorrent.com/Files/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RDEPEND=">=dev-lang/mono-2.0.1"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.23"

# The hack we do to get the dll installed in the GAC makes the unit-tests
# defunct.
RESTRICT="test"

src_prepare() {
	sed -i	\
		-e "/InternalsVisibleTo/d" \
		MonoTorrent/AssemblyInfo.cs* || die
}

src_compile() {
	emake -j1 ASSEMBLY_COMPILER_COMMAND="/usr/bin/gmcs -keyfile:${FILESDIR}/mono.snk"
}

src_install() {
	egacinstall $(find . -name "MonoTorrent.dll")
	dodir /usr/$(get_libdir)/pkgconfig
	ebegin "Installing .pc file"
	sed  \
		-e "s:@LIBDIR@:$(get_libdir):" \
		-e "s:@PACKAGENAME@:${PN}:" \
		-e "s:@DESCRIPTION@:${DESCRIPTION}:" \
		-e "s:@VERSION@:${PV}:" \
		-e 's;@LIBS@;-r:${libdir}/mono/monotorrent/MonoTorrent.dll;' \
		"${FILESDIR}"/${PN}.pc.in > "${D}"/usr/$(get_libdir)/pkgconfig/${PN}.pc
	PKG_CONFIG_PATH="${D}/usr/lib64/pkgconfig/" pkg-config --exists monotorrent || die ".pc file failed to validate."
	eend $?
}
