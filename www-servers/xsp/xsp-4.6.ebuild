# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

USE_DOTNET="net45 net40 net35"
PATCHDIR="${FILESDIR}/2.2/"

inherit eutils systemd dotnet user autotools msbuild

DESCRIPTION="XSP is a small web server that can host ASP.NET pages"
HOMEPAGE="http://www.mono-project.com/ASP.NET"

EGIT_COMMIT="e1494fcb8c12e329631f8f335732bcaf318a4ec7"
SRC_URI="https://codeload.github.com/mono/xsp/tar.gz/${EGIT_COMMIT} -> ${PN}-${PV}.tar.gz"
RESTRICT="mirror"
S="${WORKDIR}/xsp-${EGIT_COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="+${USE_DOTNET} doc test examples developer debug"

COMMON_DEPEND="dev-db/sqlite:3
	!dev-dotnet/xsp
	"

RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/aclocal-fix.patch"

	if [ -z "$LIBTOOL" ]; then
		LIBTOOL=`which glibtool 2>/dev/null`
		if [ ! -x "$LIBTOOL" ]; then
			LIBTOOL=`which libtool`
		fi
	fi
	eaclocal -I build/m4/shamrock -I build/m4/shave $ACLOCAL_FLAGS
	if test -z "$NO_LIBTOOLIZE"; then
		${LIBTOOL}ize --force --copy
	fi
	eapply_user
	eautoconf
}

src_configure() {
	eautomake --gnu --add-missing --force --copy #nowarn

	myeconfargs=("--enable-maintainer-mode")
	use test && myeconfargs+=("--with_unit_tests")
	use doc || myeconfargs+=("--disable-docs")
	econf ${myeconfargs}
}

src_compile() {
	msbuild xsp.sln
}

pkg_preinst() {
	enewgroup aspnet
	enewuser aspnet -1 -1 /tmp aspnet

	# enewuser www-data
	# www-data - is from debian, i think it's the same as aspnet here
}

src_install() {
	emake DESTDIR="${ED}" install

	newinitd "${PATCHDIR}/xsp.initd" xsp
	newconfd "${PATCHDIR}/xsp.confd" xsp

	newinitd "${PATCHDIR}/mod-mono-server-r1.initd" mod-mono-server
	newconfd "${PATCHDIR}/mod-mono-server.confd" mod-mono-server

	insinto "/etc/xsp4"
	doins "${FILESDIR}/systemd/mono.webapp"

	keepdir "/etc/xsp4/conf.d/systemd"

	if use doc; then
		insinto /etc/xsp4/conf.d
		doins "${FILESDIR}/systemd/readme.txt"
	fi

	if ! use examples; then
		/bin/rm -rf "${ED}/usr/lib64/xsp/test" || die
	fi

	if test -z "$NO_LIBTOOLIZE"; then
		${LIBTOOL}ize --force --copy
	fi

	# mono-xsp4.service was original name from 
	# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=770458;filename=mono-xsp4.service;att=1;msg=5
	# I think that using the same commands as in debian 
	#     systemctl start mono-xsp4.service
	#     systemctl start mono-xsp4
	# is better than to have shorter command
	#     systemctl start xsp
	#
	# insinto /usr/lib/systemd/system
	systemd_dounit "${FILESDIR}"/systemd/mono-xsp4.service

	keepdir /var/run/aspnet
}
