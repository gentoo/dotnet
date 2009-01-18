# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/mono/mono-2.0.1.ebuild,v 1.3 2008/11/24 23:56:14 loki_val Exp $

EAPI=2

inherit mono eutils flag-o-matic multilib go-mono

DESCRIPTION="Mono runtime and class libraries, a C# compiler/interpreter"
HOMEPAGE="http://www.go-mono.com"

LICENSE="MIT LGPL-2.1 GPL-2 BSD-4 NPL-1.1 Ms-Pl GPL-2-with-linking-exception IDPL"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="xen moonlight minimal"

RDEPEND="!<dev-dotnet/pnet-0.6.12
	!dev-util/monodoc
	dev-libs/glib:2
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

MAKEOPTS="${MAKEOPTS} -j1"

RESTRICT="test"

PATCHES=(
	"${WORKDIR}/mono-2.2-libdir126.patch"
	"${FILESDIR}/mono-2.2-ppc-threading.patch"
	"${FILESDIR}/mono-2.2-uselibdir.patch"
)

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

	go-mono_src_configure \
		--disable-quiet-build \
		--with-preview \
		--with-glib=system \
		$(use_with moonlight) \
		--with-libgdiplus=$(use minimal && printf "no" || printf "installed" ) \
		$(use_with xen xen_opt) \
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
