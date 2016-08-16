# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: gac.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: functions for registring in gac
# @DESCRIPTION:
# binary packages should be able to be registred in gac too

case ${EAPI:-0} in
	0|1|2|3|4|5) die "this eclass doesn't support EAPI ${EAPI:-0}" ;;
	6) ;;
esac

DEPEND+=" dev-lang/mono"
IUSE+=" +gac"

# SRC_URI+=" https://github.com/mono/mono/raw/master/mcs/class/mono.snk"
# I was unable to setup it this ^^ way

# @FUNCTION: egacinstall
# @DESCRIPTION:  install package to GAC
egacinstall() {
	use !prefix && has "${EAPI:-0}" 0 1 2 && ED="${D}"
	gacutil -i "${1}" \
		-root "${ED}"/usr/$(get_libdir) \
		-gacdir /usr/$(get_libdir) \
		-package ${2:-${GACPN:-${PN}}} \
		|| die "installing ${1} into the Global Assembly Cache failed"
}
