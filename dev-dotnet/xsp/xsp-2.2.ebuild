# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/xsp/xsp-2.0.ebuild,v 1.3 2008/11/27 18:46:27 ssuominen Exp $

EAPI=2

inherit go-mono mono autotools

PATCHDIR="${FILESDIR}/${PV}/"

DESCRIPTION="XSP is a small web server that can host ASP.NET pages"
HOMEPAGE="http://www.go-mono.com/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE="+debug"

RDEPEND="dev-db/sqlite:3"
DEPEND="${RDEPEND}"

MAKEOPTS="${MAKEOPTS} -j1"

PATCHES=( "${PATCHDIR}/configure-fix.patch" )

pkg_preinst() {
	enewgroup aspnet
	# Give aspnet home dir of /tmp since it must create ~/.wapi
	enewuser aspnet -1 -1 /tmp aspnet
}

src_prepare() {
	go-mono_src_prepare
	eautoreconf
}

src_configure() {
	econf $(use_enable debug tracing)
}

src_install() {
	mv_command="cp -ar" go-mono_src_install
	newinitd "${FILESDIR}"/${PV}/xsp.initd xsp || die
	newinitd "${FILESDIR}"/${PV}/mod-mono-server.initd mod-mono-server || die
	newconfd "${FILESDIR}"/${PV}/xsp.confd xsp || die
	newconfd "${FILESDIR}"/${PV}/mod-mono-server.confd mod-mono-server || die

	keepdir /var/run/aspnet
}

pkg_postinst() {
	chown aspnet:aspnet /var/run/aspnet
}
