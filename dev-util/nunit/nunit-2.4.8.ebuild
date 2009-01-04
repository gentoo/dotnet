# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit mono multilib eutils

MY_PN=NUnit
MY_P="${MY_PN}-${PV}"

DESCRIPTION=".NET unit testing framework"
HOMEPAGE="http://www.nunit.org/"
SRC_URI="mirror://sourceforge/nunit/${MY_P}-src.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

IUSE="debug"

RDEPEND=">=dev-lang/mono-2.2_rc1
	!<dev-util/mono-tools-2.2_rc1"
DEPEND="${RDEPEND}
	app-arch/unzip
	dev-dotnet/nant"

#needs nant-0.86, I think.
RESTRICT="test"

S="${WORKDIR}/src"

src_compile() {
	use debug && buildtype=debug || buildtype=release
	nant \
		-t:mono-2.0 \
		-D:build.x86=false \
		-D:build.gui=false \
		${buildtype} \
		build || die

}

src_test() {
	nant \
		-t:mono-2.0 \
		-D:build.x86=false \
		-D:build.gui=false \
		test || die
}

src_install() {
	nant \
		-t:mono-2.0 \
		-D:build.x86=false \
		-D:build.gui=false \
		${buildtype} \
		copy-bins || die
	cd "${WORKDIR}/package/${MY_P}/bin"
	rm -f *test* *x86* runFile* fit* *fixtures*
	for assembly in nunit*.dll
	do
		egacinstall "${assembly}"
	done
	insinto /usr/$(get_libdir)/mono/${PN}
	for exe in *.exe
	do
		doins *.exe || die "doins $exe failed"
		make_wrapper "${exe%.exe}" "mono /usr/$(get_libdir)/mono/${PN}/${exe}" || die "make_wrapper $exe failed"
	done
	dosym nunit-console /usr/bin/nunit-console2
	generate_pkgconfig "${PN}" "${MY_PN}" || die
}

generate_pkgconfig() {
	ebegin "Generating .pc file"
	local	dll \
		LSTRING='Libs:' \
		pkgconfig_filename="${1:-${PN}}" \
		pkgconfig_pkgname="${2:-${pkgconfig_filename}}" \
		pkgconfig_description="${3:-${DESCRIPTION}}"

	dodir "/usr/$(get_libdir)/pkgconfig"
	cat <<- EOF -> "${D}/usr/$(get_libdir)/pkgconfig/${pkgconfig_filename}.pc"
		prefix=/usr
		exec_prefix=\${prefix}
		libdir=\${prefix}/$(get_libdir)
		Name: ${pkgconfig_pkgname}
		Description: ${pkgconfig_description}
		Version: ${PV}
	EOF
	for dll in "${D}"/usr/$(get_libdir)/mono/${pkgconfig_filename}/*.dll
	do
		LSTRING="${LSTRING} -r:"'${libdir}'"/mono/${pkgconfig_filename}/${dll##*/}"
	done
	printf "${LSTRING}" >> "${D}/usr/$(get_libdir)/pkgconfig/${pkgconfig_filename}.pc"
	PKG_CONFIG_PATH="${D}/usr/$(get_libdir)/pkgconfig/" pkg-config --silence-errors --libs ${pkgconfig_filename} &> /dev/null
	eend $?
}

