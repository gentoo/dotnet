# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

USE_DOTNET="net35 net40 net45"
PATCHDIR="${FILESDIR}/2.2/"

inherit eutils dotnet user git-r3 autotools-utils

DESCRIPTION="XSP is a small web server that can host ASP.NET pages"
HOMEPAGE="https://www.mono-project.com/ASP.NET"

EGIT_REPO_URI="git://github.com/mono/${PN}.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="doc test"

RDEPEND="dev-db/sqlite:3"
DEPEND="${RDEPEND}"

src_prepare() {
	# epatch "${FILESDIR}/aclocal-fix.patch"

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
	myeconfargs=("--enable-maintainer-mode")
	use test && myeconfargs+=("--with_unit_tests")
	use doc || myeconfargs+=("--disable-docs")
	eautomake --gnu --add-missing --force --copy #nowarn
	autotools-utils_src_configure
}

src_compile() {
	autotools-utils_src_compile
}

pkg_preinst() {
	enewgroup aspnet
	enewuser aspnet -1 -1 /tmp aspnet
}

src_install() {
	mv_command="cp -ar" autotools-utils_src_install
	newinitd "${PATCHDIR}"/xsp.initd xsp
	newinitd "${PATCHDIR}"/mod-mono-server-r1.initd mod-mono-server
	newconfd "${PATCHDIR}"/xsp.confd xsp
	newconfd "${PATCHDIR}"/mod-mono-server.confd mod-mono-server

	keepdir /var/run/aspnet
}
