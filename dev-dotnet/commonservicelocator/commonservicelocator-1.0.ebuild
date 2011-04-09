# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit base mono

DESCRIPTION="An abstraction over IoC containers and service locators."
HOMEPAGE="http://commonservicelocator.codeplex.com/"

#Not sure whether having this 'direct' url is legal.
SRC_URI="http://download.codeplex.com/Project/Download/SourceControlFileDownload.ashx?ProjectName=commonservicelocator&changeSetId=24262 -> ${P}.zip"

LICENSE="Ms-PL"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-lang/mono"
RDEPEND="${DEPEND}"

S="${WORKDIR}/main"

PATCHES="${FILESDIR}/${P}-signing.patch"

src_prepare() {
	base_src_prepare
	cp ${FILESDIR}/${PN}.snk . || die
}

src_compile()
{
	xbuild Microsoft.Practices.ServiceLocation.sln
}

_DLL_LOCATION="Microsoft.Practices.ServiceLocation/bin/Debug"
_DLL_NAME="Microsoft.Practices.ServiceLocation.dll"

src_install() {
	pushd ${_DLL_LOCATION} &> /dev/null
	egacinstall ${_DLL_NAME}
	popd &> /dev/null

	dodir /usr/$(get_libdir)/pkgconfig
	sed  \
		-e "s:@LIBDIR@:$(get_libdir):" \
		-e "s:@PACKAGENAME@:${PN}:" \
		-e "s:@DESCRIPTION@:${DESCRIPTION}:" \
		-e "s:@VERSION@:${PV}:" \
		-e 's;@LIBS@;-r:${libdir}/mono/commonservicelocator/Microsoft.Practices.ServiceLocation.dll;' \
		"${FILESDIR}"/${PN}.pc.in > "${D}"/usr/$(get_libdir)/pkgconfig/${PN}.pc
	PKG_CONFIG_PATH="${D}/usr/$(get_libdir)/pkgconfig/" pkg-config --exists ${PN} || die ".pc file failed to validate."
	eend $?

}
