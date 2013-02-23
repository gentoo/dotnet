# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/mono/mono-3.0.5.ebuild $

EAPI="5"

inherit linux-info mono eutils flag-o-matic multilib go-mono pax-utils

DESCRIPTION="Mono runtime and class libraries, a C# compiler/interpreter"
HOMEPAGE="http://www.mono-project.com/Main_Page"

LICENSE="MIT LGPL-2.1 GPL-2 BSD-4 NPL-1.1 Ms-PL GPL-2-with-linking-exception IDPL"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~ppc"

IUSE="minimal pax_kernel xen doc"

COMMONDEPEND="!dev-util/monodoc
	!minimal? ( >=dev-dotnet/libgdiplus-2.10 )
	ia64? (	sys-libs/libunwind )"
RDEPEND="${COMMONDEPEND}
	|| ( www-client/links www-client/lynx )"

DEPEND="${COMMONDEPEND}
	sys-devel/bc
	virtual/yacc
	pax_kernel? ( sys-apps/paxctl )"

RESTRICT="test"

QA_FLAGS_IGNORED="/usr/lib64/mono/4.5/mcs.exe.so \
	/usr/lib64/mono/4.5/mscorlib.dll.so"

pkg_setup() {
	if use kernel_linux
	then
		get_version
		if linux_config_exists
		then
			if linux_chkconfig_present SYSVIPC
			then
				einfo "CONFIG_SYSVIPC is set, looking good."
			else
				eerror "If CONFIG_SYSVIPC is not set in your kernel .config, mono will hang while compiling."
				eerror "See http://bugs.gentoo.org/261869 for more info."
				die "Please set CONFIG_SYSVIPC in your kernel .config"
			fi
		else
			ewarn "Was unable to determine your kernel .config"
			ewarn "Please note that if CONFIG_SYSVIPC is not set in your kernel .config, mono will hang while compiling."
			ewarn "See http://bugs.gentoo.org/261869 for more info."
		fi
	fi
}

src_prepare() {
	go-mono_src_prepare
	# we need to sed in the paxctl -mr in the runtime/mono-wrapper.in so it don't
	# get killed in the build proces when MPROTEC is enable. #286280
	# RANDMMAP kill the build proces to #347365
	if use pax_kernel ; then
		ewarn "We are disabling MPROTECT on the mono binary."
		sed '/exec/ i\paxctl -mr "$r/@mono_runtime@"' -i "${S}"/runtime/mono-wrapper.in
	fi
}

src_configure() {
	# mono's build system is finiky, strip the flags
	strip-flags

	# Remove this at your own peril. Mono will barf in unexpected ways.
	append-flags -fno-strict-aliasing

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
	go-mono_src_configure \
		--enable-system-aot=yes \
		--enable-static \
		--disable-quiet-build \
		--without-moonlight \
		--with-libgdiplus=$(use minimal && printf "no" || printf "installed" ) \
		$(use_with xen xen_opt) \
		--without-ikvm-native \
		--with-jit \
		--disable-dtrace \
		--with-profile4 \
		--with-sgen=$(use ppc && printf "no" || printf "yes" ) \
		$(use_with doc mcs-docs)
}

src_test() {
	echo ">>> Test phase [check]: ${CATEGORY}/${PF}"

	export MONO_REGISTRY_PATH="${T}/registry"
	export XDG_DATA_HOME="${T}/data"
	export MONO_SHARED_DIR="${T}/shared"
	export XDG_CONFIG_HOME="${T}/config"
	export HOME="${T}/home"

	emake -j1 check
}

src_install() {
	go-mono_src_install

	# Remove files not respecting LDFLAGS and that we are not supposed to provide, see Fedora
	# mono.spec and http://www.mail-archive.com/mono-devel-list@lists.ximian.com/msg24870.html
	# for reference.
	rm -f "${ED}"/usr/$(get_libdir)/mono/2.0/mscorlib.dll.so
	rm -f "${ED}"/usr/$(get_libdir)/mono/2.0/mcs.exe.so
}

#THINK!!!! Before touching postrm and postinst
#Reference phase order:
#pkg_preinst
#pkg_prerm
#pkg_postrm
#pkg_postinst

pkg_preinst() {
	local symlink
	local NUNIT_DIR="/usr/$(get_libdir)/mono/nunit"
	local pv_atom
	if  [[ "$(readlink "${EROOT}"/${NUNIT_DIR})" == *"mono-nunit"* ]]
	then
		for pv_atom in 2.2{,-r1,-r2,-r3,-r4} '2.4_pre*' '2.4_rc*' 2.4
		do
			if has_version "=dev-lang/mono-${pv_atom}"
			then
				einfo "If you just received a file collision warning message,"
				einfo "be advised that this is a known problem, which will now be fixed:"
				ebegin "Found broken symlinks created by $(best_version dev-lang/mono), fixing"
				for symlink in						\
					"${EROOT}/${NUNIT_DIR}"				\
					"${EROOT}/usr/$(get_libdir)/pkgconfig/nunit.pc"	\
					"${EROOT}/usr/bin/nunit-console"			\
					"${EROOT}/usr/bin/nunit-console2"
				do
					if [[ -L "${symlink}" ]]
					then
						rm -f "${symlink}" &> /dev/null
					fi
				done
				eend 0
				break
			fi
		done
	fi
}

pkg_postinst() {
	elog "PLEASE TAKE NOTE!"
	elog ""
	elog "Some of the namespaces supported by Mono require extra packages to be installed."
	elog "Below is a list of namespaces and the corresponding package you must install:"
	elog ""
	elog ">=x11-libs/cairo-1.6.4"
	elog "	Mono.Cairo"
	elog "Also read:"
	elog "http://www.mono-project.com/Mono.Cairo"
	elog ""
	elog ">=dev-db/firebird-2.0.4.13130.1"
	elog "	FirebirdSql.Data.Firebird"
	elog "Also read:"
	elog "http://www.mono-project.com/Firebird_Interbase"
	elog ""
	elog "dev-db/sqlite:3"
	elog "	Mono.Data.Sqlite"
	elog "Also read:"
	elog "http://www.mono-project.com/SQLite"
	elog ""
	elog ">=dev-db/oracle-instantclient-basic-10.2"
	elog "	System.Data.OracleClient"
	elog "Also read:"
	elog "http://www.mono-project.com/Oracle"
	elog ""
	elog "Mono also has support for packages that are not included in portage:"
	elog ""
	elog "No ebuild available:"
	elog "	IBM.Data.DB2"
	elog "Also read: http://www.mono-project.com/IBM_DB2"
	elog ""
	elog "No ebuild needed:"
	elog "	Mono.Data.SybaseClient"
	elog "Also read: http://www.mono-project.com/Sybase"
}
