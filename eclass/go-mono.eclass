# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/go-mono.eclass,v 1.4 2009/01/27 01:36:09 loki_val Exp $

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

GO_MONO_REL_PV="$(get_version_component_range 1-2)"

if ! has "${CATEGORY}/${PN}" "${NO_MONO_DEPEND[@]}"
then
	RDEPEND="=dev-lang/mono-${GO_MONO_REL_PV}*"
	DEPEND="${RDEPEND}"
fi

# @ECLASS-VARIABLE: PRE_URI
# @DESCRIPTION: If installing a preview, set this variable to the base
# path on ximians's servers from which to install.

DEPEND="${DEPEND}
	>=dev-util/pkgconfig-0.23
	userland_GNU? ( >=sys-apps/findutils-4.4.0 )"

if [[ "${GO_MONO_REL_PV}" = "2.4" ]]
then
	PRE_URI="http://mono.ximian.com/monobuild/preview/sources"
fi

if [[ "${PV%_rc*}" != "${PV}" ]]
then
	GO_MONO_P="${P%_rc*}"
	SRC_URI="${PRE_URI}/${PN}/${GO_MONO_P}.tar.bz2 -> ${P}.tar.bz2"
	S="${WORKDIR}/${GO_MONO_P}"
elif [[ "${PV%_pre*}" != "${PV}" ]]
then
	GO_MONO_P="${P%_pre*}"
	SRC_URI="${PRE_URI}/${PN}/${GO_MONO_P}.tar.bz2 -> ${P}.tar.bz2"
	S="${WORKDIR}/${GO_MONO_P}"
else
	GO_MONO_P=${P}
	SRC_URI="http://ftp.novell.com/pub/mono/sources/${PN}/${P}.tar.bz2"
fi

# @FUNCTION: go-mono_src_unpack
# @DESCRIPTION: Runs default()
go-mono_src_unpack() {
	default
}

# @FUNCTION: go-mono_src_prepare
# @DESCRIPTION: Runs autopatch from base.eclass, if PATCHES is set.
go-mono_src_prepare() {
	base_src_util autopatch
}

# @FUNCTION: go-mono_src_configure
# @DESCRIPTION: Runs econf, disabling static libraries and dependency-tracking.
go-mono_src_configure() {
	econf	--disable-dependency-tracking		\
		--disable-static			\
		"$@"
}

# @FUNCTION: go-mono_src_configure
# @DESCRIPTION: Runs default()
go-mono_src_compile() {
	default
}

# @ECLASS-VARIABLE: DOCS
# @DESCRIPTION: Insert path of docs you want installed. If more than one,
# consider using an array.

# @FUNCTION: go-mono_src_install
# @DESCRIPTION: Rune emake, installs common doc files, if DOCS is
# set, installs those. Gets rid of .la files.
go-mono_src_install () {
	emake -j1 DESTDIR="${D}" install || die "install failed"
	mono_multilib_comply
	local	commondoc=( AUTHORS ChangeLog README TODO )
	for docfile in "${commondoc[@]}"
	do
		[[ -e "${docfile}" ]] && dodoc "${docfile}"
	done
	if [[ "${DOCS[@]}" ]]
	then
		dodoc "${DOCS[@]}" || die "dodoc DOCS failed"
	fi
	find "${D}" -name '*.la' -exec rm -rf '{}' '+' || die "la removal failed"
}

EXPORT_FUNCTIONS src_unpack src_prepare src_configure src_compile src_install
