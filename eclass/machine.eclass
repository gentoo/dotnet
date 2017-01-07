# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: machine.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: functions for registring in machine.config
# @DESCRIPTION:
# ADO .NET data providers should be able to be registred in machine.config

inherit gac

case ${EAPI:-0} in
	0|1|2|3|4|5) die "this eclass doesn't support EAPI ${EAPI:-0}" ;;
	6) ;;
esac

DEPEND+=" >=dev-util/mono-packaging-tools-0.1.2"
RDEPEND+=" >=dev-util/mono-packaging-tools-0.1.2"

IUSE+=" +machine"

# @FUNCTION: emachineadd
# @DESCRIPTION:  install a provider into machine.config
emachineadd() {
	if use machine; then
		if ! use gac; then die 'you should enable USE="+gac" if you want USE="machine"'; fi;
		einfo "Installing $1 into machine.config"
		einfo mpt-machine --in /etc/mono/4.5/machine.config --out /etc/mono/4.5/._cfg0000_machine.config --name "$2" --invariant "$1" --dll "$3"
		      mpt-machine --in /etc/mono/4.5/machine.config --out /etc/mono/4.5/._cfg0000_machine.config --name "$2" --invariant "$1" --dll "$3" || die
	fi
}

# @FUNCTION: emachinedel
# @DESCRIPTION: remove a provider from machine.config
emachinedel() {
	if use machine; then
		einfo "Removing $1 from machine.config"
		mpt-machine --in=/etc/mono/4.5/machine.config --out=/etc/mono/4.5/._cfg0000_machine.config --name="$2" --invariant="$1" || die
	fi
}
