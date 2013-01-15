# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

USE_DOTNET="net40"

inherit nuget mono

DESCRIPTION="core framework assembly for NuGet that the rest of NuGet builds upon"
HOMEPAGE="http://nuget.org/packages/Nuget.Core"
SRC_URI=""

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="dev-lang/mono
!dev-dotnet/nuget"
RDEPEND="${DEPEND}"

pkg_pretend() {
	if [[ ${MERGE_TYPE} != buildonly ]] && has collision-protect ${FEATURES}; then
		if [ -f /usr/lib/mono/"${FRAMEWORK}"/NuGet.Core.dll]; then
			eerror "FEATURES=\"collision-protect\" is enabled, which will prevent overwriting"
			eerror "collision-protect or remove /usr/lib/mono/4.0/NuGet.Core.dll"
			die "collision-protect cannot overwrite NuGet.Core.dll"
		fi
	fi
}

src_install() {
	elog "Installing libraries"
	insinto /usr/lib/mono/"${FRAMEWORK}"/
	doins Nuget.Core."${NPV}"/lib/net40-Client/NuGet.Core.dll
}
