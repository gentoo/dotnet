# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mono.eclass,v 1.10 2008/12/26 00:37:47 loki_val Exp $

# @ECLASS: mono.eclass
# @MAINTAINER:
# dotnet@gentoo.org
# @BLURB: common settings and functions for mono and dotnet related
# packages
# @DESCRIPTION:
# The mono eclass contains common environment settings that are useful for
# dotnet packages.  Currently, it provides no functions, just exports
# MONO_SHARED_DIR and sets LC_ALL in order to prevent errors during compilation
# of dotnet packages.

inherit mono autotools eutils

TAO_PN=${TAO_PN:-taoframework}
TAO_P=${TAO_PN}-${PV}
TAO_COMPONENT_PN=${TAO_COMPONENT_PN:-${PN}}
TAO_COMPONENT_P=${TAO_COMPONENT_PN}-${PV}

DESCRIPTION="${TAO_COMPONENT_PN} module of the Tao .NET framework for OpenGL"
HOMEPAGE="http://www.taoframework.com/"
SRC_URI="mirror://sourceforge/${TAO_PN}/${TAO_P}.tar.gz"
LICENSE="MIT"
SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

RDEPEND=">=dev-lang/mono-2.0
	virtual/monodoc"
DEPEND="${DEPEND}
	>=dev-util/pkgconfig-0.23"

S="${WORKDIR}/${TAO_P}/source"

src_prepare() {
	epatch "${FILESDIR}/tao-${PV}-monodoc.patch"
	eautoreconf
}

src_compile() {
	cd src/Tao.OpenGl
	emake
}

src_install() {
	cd src/Tao.OpenGl
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO || die "dodoc failed"
}



