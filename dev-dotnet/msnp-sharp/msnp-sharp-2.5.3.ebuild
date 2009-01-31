# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/gtk-sharp/gtk-sharp-2.12.7-r5.ebuild,v 1.1 2009/01/05 17:17:56 loki_val Exp $

EAPI="2"

inherit mono autotools

MY_PN=MSNPSharp
MY_PV=${PV//.}
MY_P=${MY_PN}_${MY_PV}

HOMEPAGE="http://code.google.com/p/msnp-sharp/"
SRC_URI="http://msnp-sharp.googlecode.com/files/${MY_P}_release_src.zip"
# http://msnp-sharp.googlecode.com/files/MSNPSharp_253_release_src.zip
DESCRIPTION="MSNPSharp is a .Net library that implements the MSN protocol."

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug"
LICENSE="|| ( LGPL-2.1 LGPL-3 )"


RDEPEND=">=dev-lang/mono-2.0"
DEPEND="${RDEPEND}
	>=dev-util/monodevelop-1.9.1
	>=dev-util/pkgconfig-0.23"

S="${WORKDIR}"

src_prepare() {
	mdtool generate-makefiles -d:Debug MSNPSharp.sln
	AT_M4DIR="${S}" eautoreconf
}

src_compile() {
	cd MSNPSharp
	emake -j1 ASSEMBLY_COMPILER_COMMAND='/usr/bin/gmcs -keyfile:Resources/msnpsharp.snk'
}

src_install() {
	cd MSNPSharp
	egacinstall bin/Debug/MSNPSharp.dll
	dodir /usr/$(get_libdir)/pkgconfig
	sed \
		-e 's:@prefix@:${pcfiledir}/../..:'				\
		-e 's:@exec_prefix@:${prefix}:'					\
		-e 's:@libdir@:${prefix}/'"$(get_libdir):"			\
		-e "s:@VERSION@:${PV}:"						\
		-e 's;@libs@; -r:${libdir}/mono/msnp-sharp/MSNPSharp.dll;'	\
		< "${FILESDIR}"/${PN}.pc.in					\
		> "${D}"/usr/$(get_libdir)/pkgconfig/msnp-sharp.pc

}
