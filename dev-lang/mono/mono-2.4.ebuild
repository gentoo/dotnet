# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/mono/mono-2.2-r3.ebuild,v 1.1 2009/01/25 13:23:40 loki_val Exp $

EAPI=2

inherit mono eutils flag-o-matic multilib go-mono

DESCRIPTION="Mono runtime and class libraries, a C# compiler/interpreter"
HOMEPAGE="http://www.go-mono.com"

LICENSE="MIT LGPL-2.1 GPL-2 BSD-4 NPL-1.1 Ms-PL GPL-2-with-linking-exception IDPL"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="xen moonlight minimal"

#Bash requirement is for += operator
COMMONDEPEND="!<dev-dotnet/pnet-0.6.12
	!dev-util/monodoc
	dev-libs/glib:2
	!minimal? ( =dev-dotnet/libgdiplus-${GO_MONO_REL_PV}* )
	ia64? (
		sys-libs/libunwind
	)"
RDEPEND="${COMMONDEPEND}
	|| ( www-client/links www-client/lynx )"

DEPEND="${COMMONDEPEND}
	sys-devel/bc
	>=app-shells/bash-3.2"
PDEPEND="dev-dotnet/pe-format"

MAKEOPTS="${MAKEOPTS} -j1"

RESTRICT="test"

PATCHES=(
	"${WORKDIR}/mono-2.2-libdir126.patch"
	"${FILESDIR}/mono-2.2-ppc-threading.patch"
	"${FILESDIR}/mono-2.2-uselibdir.patch"
)

pkg_setup() {
	MONO_NUNIT_DIR="/usr/$(get_libdir)/mono/mono-nunit"
	NUNIT_DIR="/usr/$(get_libdir)/mono/nunit"
}

src_prepare() {
	sed -e "s:@MONOLIBDIR@:$(get_libdir):" \
		< "${FILESDIR}"/mono-2.2-libdir126.patch \
		> "${WORKDIR}"/mono-2.2-libdir126.patch ||
		die "Sedding patch file failed"
	go-mono_src_prepare
}

src_configure() {
	# mono's build system is finiky, strip the flags
	strip-flags

	#Remove this at your own peril. Mono will barf in unexpected ways.
	append-flags -fno-strict-aliasing

	#NOTE: We need the static libs for now so mono-debugger works.
	#See http://bugs.gentoo.org/show_bug.cgi?id=256264 for details
	go-mono_src_configure \
		--enable-static \
		--disable-quiet-build \
		--with-preview \
		--with-glib=system \
		$(use_with moonlight) \
		--with-libgdiplus=$(use minimal && printf "no" || printf "installed" ) \
		$(use_with xen xen_opt) \
		--without-ikvm-native \
		--with-jit \
		--disable-dtrace

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
	#Bug 255610
	sed -i -e "s:mono/2.0/mod.exe:mono/1.0/mod.exe:" \
		"${D}"/usr/bin/mod || die "Failed to fix mod."

	find "${D}"/usr/ -name '*nunit-docs*' -exec rm -rf '{}' '+' || die "Removing nunit .docs failed"

	#Standardize install paths for eselect-nunit
	dodir ${MONO_NUNIT_DIR}
	rm -f "${D}"/usr/bin/nunit-console*

	for file in "${D}"/usr/$(get_libdir)/mono/1.0/nunit*.dll "${D}"/usr/$(get_libdir)/mono/1.0/nunit*.exe
	do
		dosym ../1.0/${file##*/} ${MONO_NUNIT_DIR}/${file##*/}
	done

	make_wrapper "nunit-console" "mono ${MONO_NUNIT_DIR}/nunit-console.exe" "" "" "${MONO_NUNIT_DIR}"
	dosym nunit-console "${MONO_NUNIT_DIR}"/nunit-console2
}

#THINK!!!! Before touching postrm and postinst
#Reference phase order:
#pkg_preinst
#pkg_prerm
#pkg_postrm
#pkg_postinst

pkg_postrm() {
	if [[ "$(readlink "${ROOT}"/${NUNIT_DIR})" == *"mono-nunit" ]]
	then
		ebegin "Removing old symlinks for nunit"
		rm -rf "${ROOT}"/${NUNIT_DIR} &> /dev/null
		rm -rf "${ROOT}"/usr/bin/nunit-console &> /dev/null
		rm -rf "${ROOT}"/usr/bin/nunit-console2 &> /dev/null
		rm -rf "${ROOT}"/usr/$(get_libdir)/pkgconfig/nunit.pc &> /dev/null
		eend 0
	fi
}

pkg_postinst() {
	local -a FAIL
	local fail return=0
	if ! [[ -L "${ROOT}/${NUNIT_DIR}" ]]
	then
		einfo "No default NUnit installed, using mono-nunit as default."
		ebegin "Removing stale symlinks for nunit, if any"
		rm -rf "${ROOT}"/${NUNIT_DIR} &> /dev/null
		rm -rf "${ROOT}"/usr/bin/nunit-console &> /dev/null
		rm -rf "${ROOT}"/usr/bin/nunit-console2 &> /dev/null
		rm -rf "${ROOT}"/usr/$(get_libdir)/pkgconfig/nunit.pc &> /dev/null
		eend 0

		ebegin "Installing mono-nunit symlinks"
		ln -sf mono-nunit "${ROOT}/${NUNIT_DIR}"					|| { return=1; FAIL+=( $NUNIT_DIR ) ; }
		ln -sf ../..${NUNIT_DIR}/nunit-console  "${ROOT}"/usr/bin/nunit-console	|| { return=1; FAIL+=( /usr/bin/nunit-console ) ; }
		ln -sf ../..${NUNIT_DIR}/nunit-console2 "${ROOT}"/usr/bin/nunit-console2	|| { return=1; FAIL+=( /usr/bin/nunit-console2 ) ; }
		ln -sf mono-nunit.pc "${ROOT}"/usr/$(get_libdir)/pkgconfig/nunit.pc		|| { return=1; FAIL+=( /usr/$(get_libdir)/pkgconfig/nunit.pc ) ; }
		eend $return

		if [[ "$return" = "1" ]]
		then
			elog "These errors are non-fatal, if re-emerging mono does not solve them, file a bug."
			for fail in "${FAIL[@]}"
			do
				eerror "Linking $fail failed"
			done
		fi
	fi

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
	elog "=dev-dotnet/gluezilla-${GO_MONO_REL_PV}*"
	elog "	Mono.Mozilla"
	elog "	Mono.Mozilla.WebBrowser"
	elog "	Mono.Mozilla.Widget"
	elog "	Interop.SHDocVw"
	elog "	AxInterop.SHDocVw"
	elog "	Interop.mshtml.dll"
	elog "	System.Windows.Forms.WebBrowser"
	elog "	Microsoft.IE"
	elog "Also read:"
	elog "http://www.mono-project.com/WebBrowser"
	elog ""
	elog "dev-db/sqlite:3"
	elog "	Mono.Data.Sqlite"
	elog "	Mono.Data.SqliteClient"
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

# NOTICE: THE COPYRIGHT FILES IN THE TARBALL ARE UNCLEAR!
# WHENEVER YOU THINK SOMETHING IS GPL-2+, IT'S ONLY GPL-2
# UNLESS MIGUEL DE ICAZA HIMSELF SAYS OTHERWISE.

# mono
# The code we use is LGPL, but contributions must be made under the MIT/X11
# license, so Novell can serve its paying customers. Exception is mono/man.
# LICENSE="LGPL-2.1"

	# mono/man
	# LICENSE="MIT"

# mcs/mcs
# mcs/gmcs
# LICENSE="GPL-2 MIT"

# tests
# LICENSE="MIT"

# mcs/class
# Except the listed exceptions:
# LICENSE="MIT"

	# mcs/class/ByteFX.Data
	# mcs/class/Npgsql
	# LICENSE="LGPL-2.1"

	# mcs/class/FirebirdSql.Data.Firebird
	# LICENSE="IDPL"

	# mcs/class/ICSharpCode.SharpZipLib
	# LICENSE="GPL-2-with-linking-exception"

	# mcs/class/MicrosoftAjaxLibrary
	# LICENSE="Ms-Pl"

	# mcs/class/Microsoft.JScript/Microsoft.JScript/TokenStream.cs
	# mcs/class/Microsoft.JScript/Microsoft.JScript/Token.cs
	# mcs/class/Microsoft.JScript/Microsoft.JScript/Parser.cs
	# mcs/class/Microsoft.JScript/Microsoft.JScript/Decompiler.cs
	# LICENSE="|| ( NPL-1.1 GPL-2 )"

# mcs/jay
# LICENSE="BSD-4"

# mcs/tools
# Except the listed exceptions:
# LICENSE="MIT"

	# mcs/tools/mdoc/Mono.Documentation/monodocs2html.cs
	# LICENSE="GPL-2"

	# mcs/tools/sqlsharp/SqlSharpCli.cs
	# LICENSE="GPL-2"

	# mcs/tools/csharp/repl.cs
	# LICENSE="|| ( MIT GPL-2 )"

	# mcs/tools/mono-win32-setup.nsi
	# LICENSE="GPL-2"

# samples
# LICENSE="MIT"
