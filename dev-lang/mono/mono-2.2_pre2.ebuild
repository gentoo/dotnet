# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/mono/mono-2.0.1.ebuild,v 1.3 2008/11/24 23:56:14 loki_val Exp $

EAPI=2

inherit mono base eutils flag-o-matic multilib autotools

DESCRIPTION="Mono runtime and class libraries, a C# compiler/interpreter"
HOMEPAGE="http://www.go-mono.com"
SRC_URI="http://mono.ximian.com/mono-packagers/mono-2.2.tar.bz2 -> ${P}.tar.bz2"

LICENSE="|| ( GPL-2 LGPL-2 X11 )"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND="!<dev-dotnet/pnet-0.6.12
		>=dev-libs/glib-2.6
		=dev-dotnet/libgdiplus-${PV}*
	ia64? ( sys-libs/libunwind )"

DEPEND="${RDEPEND}
		sys-devel/bc
		>=dev-util/pkgconfig-0.19"
PDEPEND="dev-dotnet/pe-format"

RESTRICT="test"

S=${WORKDIR}/${P%_pre*}

#Threading and mimeicon patches from Fedora CVS. Muine patch from Novell. Pointer conversions patch from Debian.

src_configure() {
	# mono's build system is finiky, strip the flags
	strip-flags

	#Remove this at your own peril. Mono will barf in unexpected ways.
	append-flags -fno-strict-aliasing

	econf	--disable-dependency-tracking \
		--disable-quiet-build \
		--with-moonlight=yes \
		--with-preview=yes \
		--with-glib=system \
		--with-gc=included \
		--with-libgdiplus=installed \
		--with-tls=$(use arm && printf "pthread" || printf "__thread" ) \
		--with-sigaltstack=$((use x86 || use amd64) && printf "yes" || printf "no" ) \
		--with-ikvm-native=no \
		--with-jit=yes

	# dev-dotnet/ikvm provides ikvm-native
}

src_compile() {
	emake -j1
# EXTERNAL_MCS=false EXTERNAL_MONO=false

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
	emake DESTDIR="${D}" install || die "install failed"

	dodoc AUTHORS ChangeLog NEWS README

	docinto docs
	dodoc docs/*

	docinto libgc
	dodoc libgc/ChangeLog
}
