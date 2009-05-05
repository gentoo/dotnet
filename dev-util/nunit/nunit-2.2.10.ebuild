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
SLOT="2.2"
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

src_prepare() {
	epatch "${FILESDIR}/nunit22-mono.patch"
	epatch "${FILESDIR}/nunit22-key.patch"
}

src_compile() {
	use debug && buildtype=debug || buildtype=release
	nant \
		mono-2.0 \
		-D:build.x86=false \
		-D:build.gui=false \
		${buildtype} \
		build || die

}

src_test() {
	nant \
		mono-2.0 \
		-D:build.x86=false \
		-D:build.gui=false \
		test || die
}

src_install() {
	nant \
		mono-2.0 \
		-D:build.x86=false \
		-D:build.gui=false \
		${buildtype} \
		copy-bins || die
	cd "${WORKDIR}/src/package/${MY_P}/bin" || die "Directory does not exist"
	rm -f *test* *x86* runFile* fit* *fixtures*
	for assembly in nunit*.dll *.exe
	do
		egacinstall "${assembly}" "${PN}-${SLOT}"
	done
	generate_pkgconfig "${PN}-${SLOT}" "${MY_PN}" || die
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

