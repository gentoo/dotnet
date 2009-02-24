# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-apache/mod_mono/mod_mono-2.2.ebuild,v 1.1 2009/01/18 17:46:53 loki_val Exp $

EAPI=2

# DRAGONS: Watch the order of these.

inherit apache-module eutils go-mono mono

KEYWORDS="~x86 ~amd64"

DESCRIPTION="Apache module for Mono."
HOMEPAGE="http://www.go-mono.com/"
LICENSE="Apache-2.0"
SLOT="0"
IUSE="aspnet2 debug"

DEPEND="=dev-dotnet/xsp-${GO_MONO_REL_PV}*"
RDEPEND="${DEPEND}"

APACHE2_MOD_CONF="2.2/70_${PN}"
APACHE2_MOD_DEFINE="MONO"

DOCFILES="AUTHORS ChangeLog COPYING INSTALL NEWS README"

need_apache2

src_prepare() {
	use aspnet2 && epatch "${FILESDIR}/mono_auto_application_aspnet2.patch"
}

src_configure() {
	go-mono_src_configure \
		$(use_enable debug) \
		|| die "econf failed"
}

src_install() {
	go-mono_src_install
	find "${D}" -name 'mod_mono.conf' -delete || die "failed to remove mod_mono.conf"
	if [[ -n "${APACHE2_MOD_CONF}" ]] ; then
		insinto "${APACHE_MODULES_CONFDIR}"
		set -- ${APACHE2_MOD_CONF}
		newins "${FILESDIR}/${1}.conf" "$(basename ${2:-$1}).conf" \
			|| die "internal ebuild error: '${FILESDIR}/${1}.conf' not found"
	fi
}

pkg_postinst() {
	apache-module_pkg_postinst

	elog "To enable mod_mono, add \"-D MONO\" to your Apache's"
	elog "conf.d configuration file. Additionally, to view sample"
	elog "ASP.NET applications, add \"-D MONO_DEMO\" too."
	elog ""
	elog "If you want mod_mono to handle AutoHosting requests using"
	elog "ASP.NET 2.0 engine, enable the aspnet2 USE flag."
}
