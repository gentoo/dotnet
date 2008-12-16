# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/xsp/xsp-2.0.ebuild,v 1.3 2008/11/27 18:46:27 ssuominen Exp $

EAPI=2

inherit mono multilib eutils

DESCRIPTION="XSP ASP.NET host"
HOMEPAGE="http://www.go-mono.com/"
SRC_URI="http://mono.ximian.com/monobuild/preview/sources/xsp/${P%_pre*}.tar.bz2 -> ${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE=""

RDEPEND=">=dev-lang/mono-${PV}
		  =dev-db/sqlite-3*"
DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.20"

S=${WORKDIR}/${P%_pre*}

pkg_preinst() {
	enewgroup aspnet

	# Give aspnet home dir of /tmp since it must create ~/.wapi
	enewuser aspnet -1 -1 /tmp aspnet
}

src_compile() {
	emake -j1  || {
		echo
		eerror "If xsp fails to build, try unmerging and re-emerging it."
		die "make failed"
	}
}

src_install() {
	make DESTDIR="${D}" install || die

	newinitd "${FILESDIR}"/2.0/xsp.initd xsp || die
	newinitd "${FILESDIR}"/2.0/mod-mono-server.initd mod-mono-server || die
	newconfd "${FILESDIR}"/2.0/xsp.confd xsp || die
	newconfd "${FILESDIR}"/2.0/mod-mono-server.confd mod-mono-server || die

	keepdir /var/run/aspnet

	dodoc README ChangeLog AUTHORS INSTALL NEWS
}

pkg_postinst() {
	chown aspnet:aspnet /var/run/aspnet
}
