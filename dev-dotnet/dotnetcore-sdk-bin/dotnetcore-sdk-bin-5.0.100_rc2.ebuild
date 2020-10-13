# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit eutils

DESCRIPTION=".NET Core SDK - binary precompiled for glibc"
HOMEPAGE="https://www.microsoft.com/net/core"
LICENSE="MIT"

SRC_URI="
amd64? ( https://download.visualstudio.microsoft.com/download/pr/69cb8922-7bb0-4d3a-aa92-8cb885fdd0a6/2fd4da9e026f661caf8db9c1602e7b2f/dotnet-sdk-5.0.100-rc.2.20479.15-linux-x64.tar.gz )
arm? ( https://download.visualstudio.microsoft.com/download/pr/068ebc6e-4a1d-45ec-a766-733a142f2839/e0da4c731c943ca2b267c15edb565108/dotnet-sdk-5.0.100-rc.2.20479.15-linux-arm.tar.gz )
arm64? ( https://download.visualstudio.microsoft.com/download/pr/b416bc12-1478-4241-bc31-6fe68f8b73b6/582f018a97172f4975973390cf3f58e7/dotnet-sdk-5.0.100-rc.2.20479.15-linux-arm64.tar.gz )
"

SLOT="5.0"
KEYWORDS=""

QA_PREBUILT="*"
RESTRICT="splitdebug"

# The sdk includes the runtime-bin and aspnet-bin so prevent from installing at the same time
# dotnetcore-sdk is the source based build

RDEPEND="
	>=dev-dotnet/dotnetcore-sdk-bin-common-${PV}
	>=sys-apps/lsb-release-1.4
	>=sys-devel/llvm-4.0
	>=dev-util/lldb-4.0
	>=sys-libs/libunwind-1.1-r1
	>=dev-libs/icu-57.1
	>=dev-util/lttng-ust-2.8.1
	|| ( >=dev-libs/openssl-1.0.2h-r2 >=dev-libs/openssl-compat-1.0.2h-r2 )
	>=net-misc/curl-7.49.0
	>=app-crypt/mit-krb5-1.14.2
	>=sys-libs/zlib-1.2.8-r1
	!dev-dotnet/dotnetcore-sdk
	!dev-dotnet/dotnetcore-sdk-bin:0
	!dev-dotnet/dotnetcore-runtime-bin
	!dev-dotnet/dotnetcore-aspnet-bin"

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

	# Skip the common files
	find . -maxdepth 1 -type f -exec rm -f {} \; || die
	rm -rf ./packs/NETStandard.Library.Ref || die
}

src_install() {
	local dest="opt/dotnet_core"
	dodir "${dest}"

	local ddest="${D}/${dest}"
	cp -a "${S}"/* "${ddest}/" || die
}
