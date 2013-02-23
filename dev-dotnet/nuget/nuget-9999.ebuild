# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
USE_DOTNET="net40 net45"

inherit git-2 mono

EGIT_REPO_URI="https://git01.codeplex.com/nuget"
DESCRIPTION="Nuget - .NET Package Manager"
HOMEPAGE="http://nuget.codeplex.com"
SRC_URI=""

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="dev-lang/mono"
RDEPEND="${DEPEND}"

src_prepare() {
	#TODO: match FRAMEWORK
	./build.sh
}

src_install() {
	elog "Installing libraries"
	insinto /usr/lib/mono/NuGet/"${FRAMEWORK}"/
	doins src/CommandLine/obj/Mono\ Release/NuGet.exe || die
	doins src/Core/obj/Mono\ Release/NuGet.Core.dll || die
}

pkg_postinst() {
	mozroots --import --sync --machine
	echo "mono /usr/lib/mono/NuGet/${FRAMEWORK}/NuGet.exe \"\$@\"" > /usr/bin/nuget
	chmod 777 /usr/bin/nuget
}
