# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: nuget.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: Common functionality for nuget apps
# @DESCRIPTION: my idea of nuget was following:
# introduce nuget IUSE flag for packages that are on nuget to download them from nuget. (if sources fails with some reason or dependies is complicated or if user just want binaries).
# or maybe even introduce few packages that just downloads and instulls from nuget, reason is obviously - easy maintaince

inherit nupkg

# @FUNCTION: nuget_src_unpack
# @DESCRIPTION: Runs nuget
# Here is usage example where nuget is alternative way: https://github.com/gentoo/dotnet/blob/master/dev-dotnet/fake
# Src_compile does nothing and src_install just installs sources from nuget_src_unpack
nuget_src_unpack() {
	default
	nuget install "${NPN}" -Version "${NPV}" -OutputDirectory "${P}"
}

# @FUNCTION: nuget_src_configure
# @DESCRIPTION: Runs nothing.
nuget_src_configure() { :; }

# @FUNCTION: nuget_src_compile
# @DESCRIPTION: Runs nothing.
nuget_src_compile() { :; }

EXPORT_FUNCTIONS src_unpack src_configure src_compile
