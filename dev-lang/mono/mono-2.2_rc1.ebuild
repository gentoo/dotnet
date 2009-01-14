# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/mono/mono-2.0.1.ebuild,v 1.3 2008/11/24 23:56:14 loki_val Exp $

EAPI=2

inherit go-mono mono base eutils flag-o-matic multilib

DESCRIPTION="Mono runtime and class libraries, a C# compiler/interpreter"
HOMEPAGE="http://www.go-mono.com"

LICENSE="|| ( GPL-2 LGPL-2 X11 )"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86 ~x86-fbsd"
IUSE="xen moonlight minimal"

RDEPEND="!<dev-dotnet/pnet-0.6.12
	!dev-util/monodoc
	dev-libs/glib:2
	>=dev-libs/boehm-gc-7.1[threads]
	!minimal? (
		=dev-dotnet/libgdiplus-${GO_MONO_REL_PV}*
		=dev-dotnet/gluezilla-${GO_MONO_REL_PV}*
	)
	ia64? (
		sys-libs/libunwind
	)"
DEPEND="${RDEPEND}
	sys-devel/bc"
PDEPEND="dev-dotnet/pe-format"

PATCHES=( "${FILESDIR}/${PN}-2.2-b.n.c-450782.patch" )

MAKEOPTS="${MAKEOPTS} -j1"

src_configure() {
	# mono's build system is finiky, strip the flags
	strip-flags

	#Remove this at your own peril. Mono will barf in unexpected ways.
	append-flags -fno-strict-aliasing

	go-mono_src_configure \
		--disable-quiet-build \
		$(use_with moonlight) \
		--with-preview \
		--with-glib=system \
		--with-gc=boehm \
		--with-libgdiplus=$(use minimal && printf "no" || printf "installed" ) \
		$(use_with xen xenopt) \
		--without-ikvm-native \
		--with-jit

}

src_test() {
	vecho ">>> Test phase [check]: ${CATEGORY}/${PF}"

        export MONO_REGISTRY_PATH="${T}/registry"
        export XDG_DATA_HOME="${T}/data"
        export MONO_SHARED_DIR="${T}/shared"
        export XDG_CONFIG_HOME="${T}/config"
        export HOME="${T}/home"

	emake -j1 check
}

src_install() {
	go-mono_src_install

	docinto docs
	dodoc docs/*

	docinto libgc
	dodoc libgc/ChangeLog

	find "${D}"/usr/ -name '*nunit-docs*' -exec rm -rf '{}' '+' || die "Removing nunit .docs failed"

	#Standardize install paths for eselect-nunit
	local nunit_dir="/usr/$(get_libdir)/mono/nunit-mono-${PV}-internal"
	dodir ${nunit_dir}
	rm -f "${D}"/usr/bin/nunit-console*

	for file in "${D}"/usr/$(get_libdir)/mono/1.0/nunit*.dll "${D}"/usr/$(get_libdir)/mono/1.0/nunit*.exe
	do
		dosym ../1.0/${file##*/} ${nunit_dir}/${file##*/}
	done

	make_wrapper "nunit-console" "mono ${nunit_dir}/nunit-console.exe" "" "" "${nunit_dir}"
	dosym nunit-console "${nunit_dir}"/nunit-console2
}
