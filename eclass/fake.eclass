# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: fake.eclass
# @MAINTAINER: Heather@Cynede.net
# @BLURB: Common functionality for fake apps
# @DESCRIPTION: Common functionality needed by fake build system.

inherit dotnet

NO_FAKE_DEPEND="dev-lang/fsharp dev-dotnet/fake"
DEPEND="${NO_FAKE_DEPEND}"

# @FUNCTION: fake_src_configure
# @DESCRIPTION: Runs nothing
fake_src_configure() { :; }

# @FUNCTION: fake_src_compile
# @DESCRIPTION: Runs fake.
fake_src_compile() {
	fake || die "fake build failed"
}

# @FUNCTION: fake_src_install
# @DESCRIPTION: installs common doc files, if DOCS is
# set, installs those. Gets rid of .la files.
fake_src_install () {
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

EXPORT_FUNCTIONS src_configure src_compile src_install
