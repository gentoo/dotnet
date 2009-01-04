# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/ikvm/ikvm-0.36.0.11-r1.ebuild,v 1.1 2008/12/28 20:05:52 loki_val Exp $

EAPI=2

inherit eutils mono multilib

CLASSPATH_P="classpath-0.95"

DESCRIPTION="Java VM for .NET"
HOMEPAGE="http://www.ikvm.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.zip
		 mirror://sourceforge/${PN}/classpath-0.95-stripped.zip
		 mirror://sourceforge/${PN}/openjdk-b13-stripped.zip"
LICENSE="as-is"

SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

RDEPEND=">=dev-lang/mono-2
	dev-libs/glib"
DEPEND="${RDEPEND}
	!dev-dotnet/ikvm-bin
	>=dev-dotnet/nant-0.85
	>=virtual/jdk-1.6
	app-arch/unzip
	dev-util/pkgconfig"

src_prepare() {
	# Remove unneccesary executables and
	# Windows-only libraries (bug #186837)
	rm bin/{IKVM*dll,*.exe,JVM.DLL,ikvm-native.dll}

	# We use javac instead of ecj because of
	# memory related problems (see bug #183526)
	sed -i \
		-e 's#ecj#javac#' \
		-e 's#-1.5#-J-mx384M -source 1.5#' \
		classpath/classpath.build \
		|| die "sed failed"

	sed -i -e 's:pkg-config --cflags:pkg-config --cflags --libs:' \
		native/native.build || die "sed failed"

	mkdir -p "${T}"/home/test
}

src_configure() {
	:
}

src_compile() {
	XDG_CONFIG_HOME="${T}/home/test" nant -t:mono-2.0 signed || die "ikvm build failed"
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
		LSTRING="${LSTRING} -r:"'${libdir}'"/mono/IKVM/${dll##*/}"
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

	for dll in bin/IKVM.*.dll
	do
		dllbase=${dll##*/}
		ebegin "Installing and registering ${dllbase}"
		gacutil -i bin/${dllbase} -root "${D}"/usr/$(get_libdir) \
			-gacdir /usr/$(get_libdir) -package IKVM &>/dev/null
		eend $? || die "Failed installing ${dllbase}"
	done
}
