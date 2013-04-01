# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: go-mono.eclass
# @MAINTAINERS:
# heather@cynede.net
# @BLURB: Common functionality for go-mono.org apps
# @DESCRIPTION:
# Common functionality needed by all go-mono.org apps.

inherit base versionator mono autotools git-2

PRE_URI="http://mono.ximian.com/monobuild/preview/sources"

GIT_PN="${PN/mono-debugger/debugger}"

ESVN_STORE_DIR="${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/svn-src/mono"

GO_MONO_SUB_BRANCH=${GO_MONO_SUB_BRANCH}

if [[ "${PV}" == "9999" ]]
then
	GO_MONO_P=${P}
	EGIT_REPO_URI="http://github.com/mono/${GIT_PN}.git"
	SRC_URI=""
elif [[ "${PV%.9999}" != "${PV}" ]]
then
	GO_MONO_P=${P}
	EGIT_REPO_URI="http://github.com/mono/${GIT_PN}.git"
	EGIT_BRANCH="mono-$(get_version_component_range 1)-$(get_version_component_range 2)${GO_MONO_SUB_BRANCH}"
	SRC_URI=""
else
	GO_MONO_P=${P}
	EGIT_REPO_URI="http://github.com/mono/${GIT_PN}.git"
	EGIT_BRANCH="master"
	EGIT_TAG="mono-${PN}"
	SRC_URI="" #S="${WORKDIR}/${PN}-${P}"
fi

NO_MONO_DEPEND=( "dev-lang/mono" "dev-dotnet/libgdiplus" "dev-dotnet/gluezilla" )

if [[ "$(get_version_component_range 3)" != "9999" ]]
then
	GO_MONO_REL_PV="$(get_version_component_range 1-2)"
else
	GO_MONO_REL_PV="${PV}"
fi

if ! has "${CATEGORY}/${PN}" "${NO_MONO_DEPEND[@]}"
then
	RDEPEND="dev-lang/mono" # = -${GO_MONO_REL_PV}*
	DEPEND="${RDEPEND}"
fi

DEPEND="${DEPEND}
	virtual/pkgconfig
	userland_GNU? ( >=sys-apps/findutils-4.4.0 )"

# @FUNCTION: go-mono-2_src_unpack
# @DESCRIPTION: Runs default()
go-mono-2_src_unpack() {
	default
	git-2_src_unpack
}

# @FUNCTION: go-mono-2_src_prepare
# @DESCRIPTION: Runs autopatch from base.eclass, if PATCHES is set.
go-mono-2_src_prepare() {
	base_src_prepare
	[[ "$EAUTOBOOTSTRAP" != "no" ]] && eautoreconf
}

# @FUNCTION: go-mono-2_src_configure
# @DESCRIPTION:
# Runs econf, disabling static libraries and dependency-tracking.
go-mono-2_src_configure() {
	econf --disable-dependency-tracking		\
		--disable-static			\
		"$@"
}

# @FUNCTION: go-mono_src_compile
# @DESCRIPTION:
# Runs emake.
go-mono-2_src_compile() {
	emake "$@" || die "emake failed"
}

# @ECLASS-VARIABLE: DOCS
# @DESCRIPTION:
# Insert path of docs you want installed. If more than one,
# consider using an array.

# @FUNCTION: go-mono_src_install
# @DESCRIPTION:
# Rune emake, installs common doc files, if DOCS is
# set, installs those. Gets rid of .la files.
go-mono-2_src_install () {
	emake -j1 DESTDIR="${D}" "$@" install || die "install failed"
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
