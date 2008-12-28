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
IUSE="xen moonlight minimal static"

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

RESTRICT="test"

#Threading and mimeicon patches from Fedora CVS. Muine patch from Novell. Pointer conversions patch from Debian.

src_configure() {
	# mono's build system is finiky, strip the flags
	strip-flags

	#Remove this at your own peril. Mono will barf in unexpected ways.
	append-flags -fno-strict-aliasing

	go-mono_src_configure \
		--disable-quiet-build \
		$(use_with moonlight) \
		$(use_with static static_mono) \
		--with-preview \
		--with-glib=system \
		--with-gc=boehm \
		--with-libgdiplus=$(use minimal && printf "no" || printf "installed" ) \
		$(use_with xen xenopt) \
		--without-ikvm-native \
		--with-jit
#		--enable-big-arrays \

}

src_compile() {
	#We no longer need to pass any variables to emake to get mono to bootstrap.
	#That's default behavior now.
	emake -j1
	if [[ "$?" -ne "0" ]]; then
		ewarn "If you are using any hardening features such as"
		ewarn "PIE+SSP/SELinux/grsec/PAX then most probably this is the reason"
		ewarn "why build has failed. In this case turn any active security"
		ewarn "enhancements off and try emerging the package again"
		die
	fi
}



src_test() {
	vecho ">>> Test phase [check]: ${CATEGORY}/${PF}"

	mkdir -p "${T}/home/mono" || die "mkdir home failed"

	export HOME="${T}/home/mono"
	export XDG_CONFIG_HOME="${T}/home/mono"
	export XDG_DATA_HOME="${T}/home/mono"

	if ! LC_ALL=C emake -j1 check; then
		hasq test $FEATURES && die "Make check failed. See above for details."
		hasq test $FEATURES || eerror "Make check failed. See above for details."
	fi
}

src_install() {
	go-mono_src_install

	docinto docs
	dodoc docs/*

	docinto libgc
	dodoc libgc/ChangeLog
	find "${D}"/usr/{lib{,64},bin} -name '*nunit*' -exec rm -rf '{}' '+' || die "Removing nunit .dlls failed"
}
