# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

USE_DOTNET="net45"
inherit nupkg
IUSE="+${DOTNET}"

DESCRIPTION="assembly that lets you dynamically register HTTP modules at run time"
HOMEPAGE="https://www.asp.net/"
SRC_URI="http://download.mono-project.com/sources/mono/mono-4.6.0.150.tar.bz2"

LICENSE="Apache-2.0"
SLOT="0"

KEYWORDS="~amd64 ~x86"

COMMONDEPEND="
"
RDEPEND="${COMMONDEPEND}
"
DEPEND="${COMMONDEPEND}
"

S="${WORKDIR}/${PN}-$(get_version_component_range 1-3)"
