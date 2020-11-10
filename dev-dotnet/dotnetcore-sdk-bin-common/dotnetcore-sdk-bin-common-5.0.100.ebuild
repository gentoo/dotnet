# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit eutils

DESCRIPTION="Common files shared between multiple slots of .NET Core"
HOMEPAGE="https://www.microsoft.com/net/core"
LICENSE="MIT"

SRC_URI="
amd64? ( https://download.visualstudio.microsoft.com/download/pr/820db713-c9a5-466e-b72a-16f2f5ed00e2/628aa2a75f6aa270e77f4a83b3742fb8/dotnet-sdk-${PV}-linux-x64.tar.gz )
arm? ( https://download.visualstudio.microsoft.com/download/pr/e8912d3b-483b-4d6f-bd3a-3066b3194313/20f2261fe4e16e55df4bbe03c65a7648/dotnet-sdk-${PV}-linux-arm.tar.gz )
arm64? ( https://download.visualstudio.microsoft.com/download/pr/27840e8b-d61c-472d-8e11-c16784d40091/ae9780ccda4499405cf6f0924f6f036a/dotnet-sdk-${PV}-linux-arm64.tar.gz )
"

SLOT="0"
KEYWORDS="~amd64"

QA_PREBUILT="*"
RESTRICT="splitdebug"

# The sdk includes the runtime-bin and aspnet-bin so prevent from installing at the same time
# dotnetcore-sdk is the source based build

RDEPEND="
	~dev-dotnet/dotnetcore-sdk-bin-${PV}
	!dev-dotnet/dotnetcore-sdk-bin:0"

S=${WORKDIR}

src_prepare() {
	default

	# For current .NET Core versions, all the directories contain versioned files,
	# but the top-level files (the dotnet binary for example) are shared between versions,
	# and those are backward-compatible.
	# The exception from this above rule is packs/NETStandard.Library.Ref which is shared between >=3.0 versions.
	# These common files are installed by the non-slotted dev-dotnet/dotnetcore-sdk-bin-common
	# package, while the directories are installed by dev-dotnet/dotnetcore-sdk-bin which uses
	# slots depending on major .NET Core version.
	# This makes it possible to install multiple major versions at the same time.

	# Skip the versioned files (which are located inside sub-directories)
	find . -maxdepth 1 -type d ! -name . ! -name packs -exec rm -rf {} \; || die
	find ./packs -maxdepth 1 -type d ! -name packs ! -name NETStandard.Library.Ref -exec rm -rf {} \; || die
}

src_install() {
	local dest="opt/dotnet_core"
	dodir "${dest}"

	local ddest="${D}/${dest}"
	cp -a "${S}"/* "${ddest}/" || die
	dosym "/${dest}/dotnet" "/usr/bin/dotnet"

	# set an env-variable for 3rd party tools
	echo -n "DOTNET_ROOT=/${dest}" > "${T}/90dotnet"
	doenvd "${T}/90dotnet"
}
