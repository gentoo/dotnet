# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/xsp/xsp-2.2.ebuild,v 1.1 2009/01/18 17:44:04 loki_val Exp $

EAPI=2

inherit go-mono mono autotools

PATCHDIR="${FILESDIR}/2.2/"

DESCRIPTION="XSP is a small web server that can host ASP.NET pages"
HOMEPAGE="http://www.go-mono.com/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"

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
	newinitd "${PATCHDIR}"/xsp.initd xsp || die
	newinitd "${PATCHDIR}"/mod-mono-server.initd mod-mono-server || die
	newconfd "${PATCHDIR}"/xsp.confd xsp || die
	newconfd "${PATCHDIR}"/mod-mono-server.confd mod-mono-server || die

	keepdir /var/run/aspnet
}

pkg_postinst() {
	chown aspnet:aspnet /var/run/aspnet
}
