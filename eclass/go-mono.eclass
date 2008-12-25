# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mono.eclass,v 1.9 2008/12/13 13:59:02 loki_val Exp $

# @ECLASS: go-mono.eclass
# @MAINTAINER:
# dotnet@gentoo.org
# @BLURB: Common functionality for go-mono.org apps
# @DESCRIPTION:
# Common functionality needed by all go-mono.org apps.


inherit base versionator mono


NO_MONO_DEPEND=(
			"dev-lang/mono"
			"dev-dotnet/libgdiplus"
			"dev-dotnet/gluezilla"
		)

if ! has "${CATEGORY}/${PN}" "${NO_MONO_DEPEND[@]}"
then
	RDEPEND="=dev-lang/mono-$(get_version_component_range 1-2)*"
	DEPEND="${RDEPEND}"
fi

DEPEND="${DEPEND}
	>=dev-util/pkgconfig-0.23"

if [[ "$(get_version_component_range 1-2)" = "2.2" ]]
then
	PRE_URI="http://mono.ximian.com/monobuild/preview/sources"
fi

if ! [[ "${PV%_rc*}" = "${PV}" ]]
then
	MY_P="${P%_rc*}"
	SRC_URI="${PRE_URI}/${PN}/${MY_P} -> ${P}.tar.bz2"
	S="${WORKDIR}/${MY_P}"
elif ! [[ "${PV%_pre*}" = "${PV}" ]]
then
	MY_P="${P%_pre*}"
	SRC_URI="${PRE_URI}/${PN}/${MY_P} -> ${P}.tar.bz2"
	S="${WORKDIR}/${MY_P}"
else
	MY_P=${P}
	SRC_URI="http://ftp.novell.com/pub/mono/sources/${PN}/${P}.tar.bz2"
fi

go-mono_src_prepare() {
	base_src_util autopatch
}

go-mono_src_configure() {
	econf	--disable-dependency-tracking		\
		--disable-static			\
		"$@"
}

go-mono_src_install () {
	emake -j1 DESTDIR="${D}" install || die "install failed"
	local	COMMONDOC=( AUTHORS ChangeLog README TODO )
	for docfile in "${COMMONDOC[@]}"
	do
		[[ -e "${docfile}" ]] && dodoc "${docfile}"
	done
	if [[ "${DOCS[@]}" ]]
	then
		dodoc "${DOCS[@]}" || die "dodoc DOCS failed"
	fi
	find "${D}" -name '*.la' -exec rm -rf '{}' '+' || die "la removal failed"
}

EXPORT_FUNCTIONS src_install src_configure
