# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

MY_PN=libgoogle-data-mono
MY_P=${MY_PN}-${PV}

inherit mono

DESCRIPTION="This is a sample skeleton ebuild file"

HOMEPAGE="http://code.google.com/p/google-gdata/"

SRC_URI="http://google-gdata.googlecode.com/files/${MY_P}.tar.gz"

LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""
DEPEND=">=dev-lang/mono-2.0"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_compile() {
	emake PREFIX="/usr" CSC="/usr/bin/gmcs"  || die "emake failed"
}

src_install() {
	emake PREFIX="/usr" DESTDIR="${D}" install || die "emake install failed"
	dohtml RELEASE_NOTES.HTML || die  "dodoc failed"
	mono_multilib_comply
}
