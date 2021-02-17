# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit eutils

DESCRIPTION="Common files shared between multiple slots of .NET Core"
HOMEPAGE="https://www.microsoft.com/net/core"
LICENSE="MIT"

SRC_URI="
amd64? ( https://download.visualstudio.microsoft.com/download/pr/a2052604-de46-4cd4-8256-9bc222537d32/a798771950904eaf91c0c37c58f516e1/dotnet-sdk-${PV}-linux-x64.tar.gz )
arm? ( https://download.visualstudio.microsoft.com/download/pr/cd11b0d1-8d79-493f-a702-3ecbadb040aa/d24855458a90944d251dd4c68041d0b7/dotnet-sdk-${PV}-linux-arm.tar.gz )
arm64? ( https://download.visualstudio.microsoft.com/download/pr/5c2e5668-d7f9-4705-acb0-04ceeda6dadf/4eca3d1ffd92cb2b5f9152155a5529b4/dotnet-sdk-${PV}-linux-arm64.tar.gz )
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
