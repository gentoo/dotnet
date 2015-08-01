# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
AUTOTOOLS_PRUNE_LIBTOOL_FILES="all"
AUTOTOOLS_AUTORECONF=1

inherit eutils linux-info mono-env flag-o-matic pax-utils autotools-utils versionator

DESCRIPTION="Mono runtime and class libraries, a C# compiler/interpreter"
HOMEPAGE="http://www.mono-project.com/Main_Page"
SRC_URI="http://download.mono-project.com/sources/${PN}/${P}.tar.bz2"

LICENSE="MIT LGPL-2.1 GPL-2 BSD-4 NPL-1.1 Ms-PL GPL-2-with-linking-exception IDPL"
SLOT="0"

KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~amd64-linux"

IUSE="nls minimal pax_kernel xen doc debug"

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
S="${WORKDIR}/${PN}-$(get_version_component_range 1-3)"

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

	# mono build system can fail otherwise
	strip-flags

	#fix vb targets http://osdir.com/ml/general/2015-05/msg20808.html
	epatch "${FILESDIR}/add_missing_vb_portable_targets.patch"

	# Fix build on big-endian machines
	# https://bugzilla.xamarin.com/show_bug.cgi?id=31779
	epatch "${FILESDIR}/${P}-fix-decimal-ms-on-big-endian.patch"

	# Fix build when sgen disabled
	# https://bugzilla.xamarin.com/show_bug.cgi?id=32015
	epatch "${FILESDIR}/${P}-fix-mono-dis-makefile-am-when-without-sgen.patch"

	autotools-utils_src_prepare
	epatch "${FILESDIR}/systemweb3.patch"
}

src_configure() {
	local myeconfargs=(
		--disable-silent-rules
		$(use_with xen xen_opt)
		--without-ikvm-native
		--with-jit
		--disable-dtrace
		$(use_with doc mcs-docs)
		$(use_enable debug)
		$(use_enable nls)
	)

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
