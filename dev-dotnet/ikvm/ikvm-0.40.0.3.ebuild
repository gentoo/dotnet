# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/ikvm/ikvm-0.36.0.11.ebuild,v 1.1 2008/11/30 10:48:36 loki_val Exp $

EAPI=2

inherit eutils mono multilib

CLASSPATH_P="classpath-0.95"

DESCRIPTION="Java VM for .NET"
HOMEPAGE="http://www.ikvm.net/"
SRC_URI="
	http://www.frijters.net/${P}.zip
	http://www.frijters.net/openjdk6-b12-stripped-${PN^^}-${PV%.*.*}.zip
	mirror://sourceforge/${PN}/classpath-0.95-stripped.zip
	mirror://gentoo/mono.snk.bz2
	"


LICENSE="as-is"

SLOT="0"
#KEYWORDS=""
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="debugbuild"

RDEPEND=">=dev-lang/mono-2
	dev-libs/glib"
DEPEND="${RDEPEND}
	!dev-dotnet/ikvm-bin
	>=dev-dotnet/nant-0.85
	>=virtual/jdk-1.6
	app-arch/unzip
	dev-util/pkgconfig"

src_prepare() {
	epatch "${FILESDIR}/03-use_mono.snk_for_ikvm-key.patch"
	sed -i \
		-e 's:../bin/ICSharpCode.SharpZipLib.dll:ICSharpCode.SharpZipLib.dll:' \
		ikvmc/ikvmc.build || die
	# Remove unneccesary executables and
	# Windows-only libraries (bug #186837)
	rm bin/* || die
}

src_configure() {
	:
}

src_compile() {
	local NANT_OPTIONS=( "-q" )
	use debugbuild && NANT_OPTIONS="-v"

	elog "Bootstrapping process in progress."
	elog "Stage 1: Unsigned build to generate from-source assemblies"
	elog "Building ${P^^} tools"
	nant "${NANT_OPTIONS[@]}" -f:tools/tools.build || die
	elog "Building ${P^^} runtime: Pass One"
	nant "${NANT_OPTIONS[@]}" -f:runtime/runtime.build first-pass || die
	cp bin/IKVM.Runtime.dll classpath/ || die
	elog "Building ${P^^} Reflection emitter"
	nant "${NANT_OPTIONS[@]}" -f:refemit/refemit.build || die
	elog "Building ${P^^} Compiler"
	nant "${NANT_OPTIONS[@]}" -f:ikvmc/ikvmc.build || die
	elog "Building ${P^^} OpenJDK assemblies"
	nant "${NANT_OPTIONS[@]}" -f:openjdk/openjdk.build || die
	elog "Building ${P^^} runtime: Pass Two"
	nant "${NANT_OPTIONS[@]}" -f:runtime/runtime.build || die
	elog "Building ${P^^} .NET->Java Stub generator"
	nant "${NANT_OPTIONS[@]}" -f:ikvmstub/ikvmstub.build || die

	elog "Generating Java Stubs from IKVM.Runtime.dll"
	/usr/bin/mono bin/ikvmstub.exe classpath/IKVM.Runtime.dll || die
	elog "Generating Java Stubs from mscorlib.dll"
	/usr/bin/mono bin/ikvmstub.exe /usr/$(get_libdir)/mono/2.0/mscorlib.dll || die
	elog "Generating Java Stubs from System.dll"
	/usr/bin/mono bin/ikvmstub.exe /usr/$(get_libdir)/mono/2.0/System.dll || die
	elog "Generating Java Stubs from System.Core.dll"
	/usr/bin/mono bin/ikvmstub.exe /usr/$(get_libdir)/mono/2.0/System.Core.dll || die
	elog "Generating Java Stubs from System.Data.dll"
	/usr/bin/mono bin/ikvmstub.exe /usr/$(get_libdir)/mono/2.0/System.Data.dll || die
	elog "Generating Java Stubs from System.Drawing.dll"
	/usr/bin/mono bin/ikvmstub.exe /usr/$(get_libdir)/mono/2.0/System.Drawing.dll || die

	mv *.jar classpath/ || die
	rm classpath/IKVM.Runtime.dll || die
	elog "Bootstrap Process Completed. Cleaning up the mess we left."
	nant "${NANT_OPTIONS[@]}" -f:ikvm.build clean || die

	elog "Building ${P^^} from Bootstrapped assemblies."
	nant "${NANT_OPTIONS[@]}" -f:ikvm.build signed
}

generate_pkgconfig() {
	ebegin "Generating .pc file"
	local dll LSTRING="Libs:"
	dodir "/usr/$(get_libdir)/pkgconfig"
	cat <<- EOF -> "${D}/usr/$(get_libdir)/pkgconfig/${PN}.pc"
		prefix=/usr
		exec_prefix=\${prefix}
		libdir=\${prefix}/$(get_libdir)
		Name: IKVM.NET
		Description: An implementation of Java for Mono and the Microsoft .NET Framework.
		Version: ${PV}
	EOF
	for dll in "${S}"/bin/IKVM.*.dll
	do
		LSTRING="${LSTRING} -r:"'${libdir}'"/ikvm/${dll##*/}"
	done
	printf "${LSTRING}" >> "${D}/usr/$(get_libdir)/pkgconfig/${PN}.pc"
	PKG_CONFIG_PATH="${D}/usr/$(get_libdir)/pkgconfig/" pkg-config --silence-errors --libs ikvm &> /dev/null
	eend $?
}


src_install() {
	local dll dllbase exe
	insinto /usr/$(get_libdir)/${PN}
	doins bin/*.exe bin/*.so

	dodir /bin
	for exe in bin/*.exe
	do
		exebase=${exe##*/}
		ebegin "Generating wrapper for ${exebase} -> ${exebase%.exe}"
		make_wrapper ${exebase%.exe} "mono /usr/$(get_libdir)/${PN}/${exebase}"
		eend $? || die "Failed generating wrapper for ${exebase}"
	done

	generate_pkgconfig || die "generating .pc failed"

	insinto "/usr/$(get_libdir)/${PN}"
	for dll in bin/IKVM.*.dll
	do
		dllbase=${dll##*/}
		egacinstall "${dll}"
	done
}
