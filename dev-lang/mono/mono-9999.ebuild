# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
AUTOTOOLS_PRUNE_LIBTOOL_FILES="all"

inherit linux-info mono-env flag-o-matic pax-utils autotools-utils git-r3

DESCRIPTION="Mono runtime and class libraries, a C# compiler/interpreter"
HOMEPAGE="https://www.mono-project.com/Main_Page"

EGIT_REPO_URI="git://github.com/mono/${PN}.git"

LICENSE="MIT LGPL-2.1 GPL-2 BSD-4 NPL-1.1 Ms-PL GPL-2-with-linking-exception IDPL"
SLOT="0"
KEYWORDS=""
IUSE="minimal pax_kernel xen doc"

COMMONDEPEND="
	!minimal? ( >=dev-dotnet/libgdiplus-2.10 )
	ia64? (	sys-libs/libunwind )
"
RDEPEND="${COMMONDEPEND}
	|| ( www-client/links www-client/lynx )
"
DEPEND="${COMMONDEPEND}
	sys-devel/bc
	virtual/yacc
	pax_kernel? ( sys-apps/elfix )
"

pkg_pretend() {
	# If CONFIG_SYSVIPC is not set in your kernel .config, mono will hang while compiling.
	# See https://bugs.gentoo.org/261869 for more info."
	CONFIG_CHECK="SYSVIPC"
	use kernel_linux && check_extra_config
}

pkg_setup() {
	linux-info_pkg_setup
	mono-env_pkg_setup
}

src_prepare() {
	cat "${S}/mono/mini/Makefile.am.in" > "${S}/mono/mini/Makefile.am" || die

	eautoreconf
	# we need to sed in the paxctl-ng -mr in the runtime/mono-wrapper.in so it don't
	# get killed in the build proces when MPROTECT is enable. #286280
	# RANDMMAP kill the build proces to #347365
	# use paxmark.sh to get PT/XT logic #532244
	if use pax_kernel ; then
		ewarn "We are disabling MPROTECT on the mono binary."
		sed '/exec/ i\paxmark.sh -mr "$r/@mono_runtime@"' -i "${S}"/runtime/mono-wrapper.in
	fi

	# mono build system can fail otherwise
	strip-flags

	# Remove this at your own peril. Mono will barf in unexpected ways.
	append-flags -fno-strict-aliasing

	autotools-utils_src_prepare
}

src_configure() {
	# NOTE: We need the static libs for now so mono-debugger works.
	# See https://bugs.gentoo.org/show_bug.cgi?id=256264 for details
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
		--with-libgdiplus=$(use minimal && printf "no" || printf "installed" )
		$(use_with xen xen_opt)
		--without-ikvm-native
		--with-jit
		--disable-dtrace
		--with-profile4
		--with-sgen=$(use ppc && printf "no" || printf "yes" )
		$(use_with doc mcs-docs)
	)

	autotools-utils_src_configure
}

src_make() {
	# Doesn't require previous mono to be installed
	emake get-monolite-latest
	emake EXTERNAL_MCS=${PWD}/mcs/class/lib/monolite/gmcs.exe "$@"
}

src_test() {
	emake check
}

src_install() {
	autotools-utils_src_install

	# Remove files not respecting LDFLAGS and that we are not supposed to provide, see Fedora
	# mono.spec and https://www.mail-archive.com/mono-devel-list@lists.ximian.com/msg24870.html
	# for reference.
	rm -f "${ED}"/usr/lib/mono/{2.0,4.5}/mscorlib.dll.so || die
	rm -f "${ED}"/usr/lib/mono/{2.0,4.5}/mcs.exe.so || die
}
