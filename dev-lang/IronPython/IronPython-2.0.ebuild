# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit mono eutils

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
	local dll exe

	dodir /bin
	for exe in *.exe
	do
		ebegin "Generating wrapper for ${exe} -> ${exe%.exe}"
		make_wrapper ${exe%.exe} "mono /usr/$(get_libdir)/${PN}/${exe}"
		eend $? || die "Failed generating wrapper for ${exe}"
	done

	#generate_pkgconfig || die "generating .pc failed"

	for dll in *.dll
	do
		ebegin "Installing and registering ${dllbase}"
		gacutil -i ${dll} -root "${D}"/usr/$(get_libdir) \
			-gacdir /usr/$(get_libdir) -package ${PN}
		eend $? || die "Failed installing ${dll}"
	done
}
