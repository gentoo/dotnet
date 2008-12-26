# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit mono eutils python

DESCRIPTION="IronPython is Python implemented in C#"
HOMEPAGE="http://foo.bar.com/"
SRC_URI="mirror://gentoo/${P}-Src.zip
	mirror://gentoo/${P}-fepy.tar.bz2"
LICENSE="MS-Public-License"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"


S=${WORKDIR}/${P}/Src
FEPY_S=${WORKDIR}/${P}-fepy

src_prepare() {
	cd ..
	mkdir -p Bin/Debug
	bash ${FEPY_S}/pre.sh
	cd "${S}"
	epatch ${FEPY_S}/patch*
	cp ${FEPY_S}/*.build ./
}

src_configure() {
	:
}

src_compile() {
	nant -t:mono-2.0
}

src_install() {
	INSTALLDIR=/usr/$(get_libdir)/${PN}

	make_wrapper ipy "mono /usr/$(get_libdir)/${PN}/ipy.exe"

	insinto ${INSTALLDIR}
	doins *.exe *.dll
	dodir ${INSTALLDIR}/Lib
	cat <<- EOF -> "${D}/${INSTALLDIR}/Lib/site.py"
	import sys
	sys.path.append('$(python_get_libdir)')
	sys.path.append('$(python_get_sitedir)')
	EOF
}
