# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mono.eclass,v 1.9 2008/12/13 13:59:02 loki_val Exp $

# @ECLASS: go-mono.eclass
# @MAINTAINER:
# dotnet@gentoo.org
# @BLURB: Common functionality for go-mono.org apps
# @DESCRIPTION:
# Provides SRC_URIs automagically for go-mono.org apps.

if [[ "$(get_version_component_range 1-2)" = "2.2" ]]
then
	PRE_URI="http://mono.ximian.com/monobuild/preview/sources"
fi

if ! [[ "${PV%_rc*}" = "${PV}" ]]
then
	MY_P=${P%_rc*}
	SRC_URI="${PRE_URI}/${PN}gluezilla/${MY_P} -> ${P}.tar.bz2"
elif ! [[ "${PV%_pre*}" = "${PV}" ]]
then
	MY_P=${P%_pre*}
	SRC_URI="${PRE_URI}/${PN}gluezilla/${MY_P} -> ${P}.tar.bz2"
else
	MY_P=${P}
	SRC_URI="http://ftp.novell.com/pub/mono/sources/${PN}/${P}.tar.bz2
fi

