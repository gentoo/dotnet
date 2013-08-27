# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
USE_DOTNET="net45"

inherit dotnet eutils

DESCRIPTION="Nuget - .NET Package Manager"
HOMEPAGE="http://nuget.codeplex.com"
SRC_URI="http://download-codeplex.sec.s-msft.com/Download/SourceControlFileDownload.ashx?ProjectName=nuget&changeSetId=2764f6c71ea206a60eb136c27c04005975712c19 -> nuget-archive-${PV}.zip"
S=${WORKDIR}

LICENSE="Apache-2.0"
SLOT="0"

KEYWORDS="x86 amd64"
IUSE=""

# Mask 3.2.0 because of mcs compiler bug : http://stackoverflow.com/a/17926731/238232
# it fixes in 9999 but not on future stable releases yet.
DEPEND="|| ( >=dev-lang/mono-9999 <dev-lang/mono-3.2.0 )"
RDEPEND="${DEPEND}"

src_configure() {
	export EnableNuGetPackageRestore="true"
}

src_compile() {
	xbuild Build/Build.proj /p:Configuration=Release /tv:4.0 /p:TargetFrameworkVersion=v"${FRAMEWORK}" /p:Configuration="Mono Release" /t:GoMono || die
}

src_install() {
	elog "Installing libraries"

	insinto /usr/lib/mono/NuGet/"${FRAMEWORK}"/
	doins src/CommandLine/obj/Mono\ Release/NuGet.exe
	doins src/Core/obj/Mono\ Release/NuGet.Core.dll
	make_wrapper nuget "mono /usr/lib/mono/NuGet/${FRAMEWORK}/NuGet.exe \"\$@\""
}

pkg_postinst() {
	mozroots --import --sync --machine
}
