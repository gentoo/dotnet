# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: fake.eclass
# @MAINTAINER: Heather@Cynede.net
# @BLURB: Common functionality for fake apps
# @DESCRIPTION: Common functionality needed by fake build system.

inherit dotnet eutils

# @ECLASS_VARIABLE: FAKE_DEPEND
# @DESCRIPTION Set false to net depend on fake
: ${FAKE_NO_DEPEND:=}

[[ -n $FAKE_DEPEND ]] && DEPEND+=" dev-lang/fsharp dev-dotnet/fake"

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
fake_src_install() {
	dotnet_multilib_comply
	local commondoc=( AUTHORS ChangeLog README TODO )
	for docfile in "${commondoc[@]}"
	do
		[[ -e "${docfile}" ]] && dodoc "${docfile}"
	done
	if [[ "${DOCS[@]}" ]]
	then
		dodoc "${DOCS[@]}" || die "dodoc DOCS failed"
	fi
	prune_libtool_files
}

EXPORT_FUNCTIONS src_configure src_compile src_install
