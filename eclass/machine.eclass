# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: machine.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: functions for registring in machine.config
# @DESCRIPTION:
# ADO .NET data providers should be able to be registred in machine.config

case ${EAPI:-0} in
	0|1|2|3|4|5) die "this eclass doesn't support EAPI ${EAPI:-0}" ;;
	6) ;;
esac

DEPEND+=" dev-lang/mono
	dev-util/mono-packaging-tools
	"
RDEPEND+=" dev-lang/mono
	dev-util/mono-packaging-tools
	"

IUSE+=" +machine"

# @FUNCTION: emachineadd
# @DESCRIPTION:  install a provider into machine.config
emachineadd() {
	einfo "Installing $1 into machine.config"
}

# @FUNCTION: emachinedel
# @DESCRIPTION: remove a provider from machine.config
emachinedel() {
	einfo "Removing $1 from machine.config"
}
