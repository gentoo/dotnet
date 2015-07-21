# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
AUTOTOOLS_PRUNE_LIBTOOL_FILES="all"

inherit eutils linux-info mono-env flag-o-matic pax-utils autotools-utils

DESCRIPTION="Mono runtime and class libraries, a C# compiler/interpreter"
HOMEPAGE="http://www.mono-project.com/Main_Page"
SRC_URI="http://download.mono-project.com/sources/${PN}/${P}.tar.bz2"

LICENSE="MIT LGPL-2.1 GPL-2 BSD-4 NPL-1.1 Ms-PL GPL-2-with-linking-exception IDPL"
SLOT="0"

KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~amd64-linux"

#IUSE="nls minimal pax_kernel xen doc debug sgen llvm"
IUSE="nls minimal pax_kernel xen doc debug sgen"

COMMONDEPEND="
	!minimal? ( >=dev-dotnet/libgdiplus-2.10 )
	ia64? (	sys-libs/libunwind )
	nls? ( sys-devel/gettext )
"
RDEPEND="${COMMONDEPEND}
	|| ( www-client/links www-client/lynx )
"
DEPEND="${COMMONDEPEND}
	sys-devel/bc
	virtual/yacc
	pax_kernel? ( sys-apps/elfix )
"

MAKEOPTS="${MAKEOPTS} -j1" #nowarn
S="${WORKDIR}/${PN}-4.0.3"

pkg_pretend() {
	# If CONFIG_SYSVIPC is not set in your kernel .config, mono will hang while compiling.
	# See http://bugs.gentoo.org/261869 for more info."
	CONFIG_CHECK="SYSVIPC"
	use kernel_linux && check_extra_config
}

pkg_setup() {
	linux-info_pkg_setup
	mono-env_pkg_setup
}

src_prepare() {
	# we need to sed in the paxctl-ng -mr in the runtime/mono-wrapper.in so it don't
	# get killed in the build proces when MPROTEC is enable. #286280
	# RANDMMAP kill the build proces to #347365
	if use pax_kernel ; then
		ewarn "We are disabling MPROTECT on the mono binary."

		# issue 9 : https://github.com/Heather/gentoo-dotnet/issues/9
		sed '/exec "/ i\paxctl-ng -mr "$r/@mono_runtime@"' -i "${S}"/runtime/mono-wrapper.in || die "Failed to sed mono-wrapper.in"
	fi

	# strip-flags and append-flags are from
	# https://devmanual.gentoo.org/eclass-reference/flag-o-matic.eclass/index.html
	# (common functions to manipulate and query toolchain flags)

	# mono build system can fail otherwise
	strip-flags

	# Remove this at your own peril. Mono will barf in unexpected ways.
	append-flags -fno-strict-aliasing

	#fix vb targets http://osdir.com/ml/general/2015-05/msg20808.html
	epatch "${FILESDIR}/add_missing_vb_portable_targets.patch"

	autotools-utils_src_prepare
	epatch "${FILESDIR}/systemweb3.patch"
}

src_configure() {
	# Very handy to specify ./configure argument without modifying .ebuild:
	# EXTRA_ECONF="--enable-foo ......" emerge package
	# see also
	# https://devmanual.gentoo.org/ebuild-writing/functions/src_configure/configuring/index.html
	# https://devmanual.gentoo.org/eclass-reference/autotools.eclass/

	# NOTE: We need the static libs for now so mono-debugger works.
	# See http://bugs.gentoo.org/show_bug.cgi?id=256264 for details
	#
	# --without-moonlight since www-plugins/moonlight is not the only one
	# using mono: https://bugzilla.novell.com/show_bug.cgi?id=641005#c3
	#
	# --with-profile4 needs to be always enabled since it's used by default
	# and, otherwise, problems like bug #340641 appear.
	#
	# sgen fails on ppc, bug #359515
	local myeconfargs=(
		--enable-system-aot=yes
		--enable-static
		--disable-quiet-build
		--without-moonlight
		--with-libgdiplus=$(usex minimal no installed)
		$(use_with xen xen_opt)
		--without-ikvm-native
		--with-jit
		--disable-dtrace
		--with-profile4
		--with-sgen=$(usex ppc no yes)
		$(use_with doc mcs-docs)
		$(use_enable debug)
		$(use_enable nls)
	)

#	# "included" is default option - https://github.com/mono/mono#configuration-options
#	if use boehm-gc; then
#		myeconfargs+=(
#			--with-gc=included
#		)
#	fi

# this will lead to error
# make[3]: *** No rule to make target '../../mono/metadata/libmonoruntime-static.a', needed by 'monodis'.  Stop.
#	if ! use sgen; then
#		myeconfargs+=(
#			--with-sgen=no
#		)
#	fi

#	if use llvm; then
#		myeconfargs+=(
#			--enable-llvm
#			--enable-loadedllvm
#		)
#	fi

	elog "myeconfargs=${myeconfargs}"
	autotools-utils_src_configure

	# FIX for uncompilable 3.4.0 sources
	FF="${WORKDIR}/mono-3.4.0/mcs/tools/xbuild/targets/Microsoft.Portable.Common.targets"
	rm -f $FF
	touch $FF
	echo '<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">' >> $FF
	echo '    <Import Project="..\\Microsoft.Portable.Core.props" />' >> $FF
	echo '    <Import Project="..\\Microsoft.Portable.Core.targets" />' >> $FF
	echo '</Project>' >> $FF
}

src_compile() {
	nonfatal autotools-utils_src_compile || {
		eqawarn "maintainer of this ebuild has no idea why it fails. If you happen to know how to fix it - please let me know"
		autotools-utils_src_compile
	 }
}

src_test() {
	cd mcs/tests || die
	emake check
}

src_install() {
	autotools-utils_src_install

	elog "Rewriting symlink"
	# you have mono-boehm and mono-sgen executables
	# mono is just a symlink to mono-sgen
	if use sgen; then
		dosym mono-sgen /usr/bin/mono
	else
		dosym mono-boehm /usr/bin/mono
	fi
}
