# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: nuget.eclass
# @MAINTAINER: Heather@Cynede.net
# @BLURB: Common functionality for nuget apps
# @DESCRIPTION: Common functionality needed by fake build system.

inherit mono

if [[ $PN == *_* ]]
then
   	NPN=${PN/_/.}
else
	NPN=${PN}
fi
if [[ $PV == *_alpha* ]]
then
   	NPV=${PV/_/-}
else
   	NPV=${PV}
fi

# @FUNCTION: nuget_src_unpack
# @DESCRIPTION: Runs nuget.
nuget_src_unpack() { 
	nuget install "${NPN}" -Version "${NPV}" -OutputDirectory "${P}"
}

# @FUNCTION: nuget_src_configure
# @DESCRIPTION: Runs nothing.
nuget_src_configure() { :; }

# @FUNCTION: nuget_src_compile
# @DESCRIPTION: Runs nothing.
nuget_src_compile() { :; }

# @FUNCTION: nuget_src_install
# @DESCRIPTION: Runs nothing.
nuget_src_install () { :; }

EXPORT_FUNCTIONS src_unpack src_configure src_compile src_install
