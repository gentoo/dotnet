# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit eutils

MY_PV="${PV}"

DESCRIPTION=".NET Core SDK - binary precompiled for glibc"
HOMEPAGE="https://www.microsoft.com/net/core"
LICENSE="MIT"

SRC_URI="
amd64? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${MY_PV}/dotnet-sdk-${MY_PV}-linux-x64.tar.gz )
arm? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${MY_PV}/dotnet-sdk-${MY_PV}-linux-arm.tar.gz )
arm64? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${MY_PV}/dotnet-sdk-${MY_PV}-linux-arm64.tar.gz )
"

SLOT="6.0"
KEYWORDS=""

QA_PREBUILT="*"
RESTRICT="splitdebug"

# The sdk includes the runtime-bin and aspnet-bin so prevent from installing at the same time
# dotnetcore-sdk is the source based build

RDEPEND="
	app-crypt/mit-krb5
	>=dev-dotnet/dotnetcore-sdk-bin-common-${PV}
	dev-libs/icu
	|| ( dev-libs/openssl dev-libs/openssl-compat:1.0.0 )
	dev-util/lldb
	dev-util/lttng-ust
	net-misc/curl
	sys-apps/lsb-release
	sys-devel/llvm
	sys-libs/libunwind
	sys-libs/zlib"

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

	# 6.0.100 is SDK feature band which will not change between minor increases, so 6.0.101, 6.102
	# will still have same 6.0.100 SDK feature band in the name. Thus I have to hard code this
	# https://github.com/dotnet/sdk/pull/18823#issuecomment-915603684
	local workloads="metadata/workloads/${SLOT}.100"
	{ mkdir -p "${workloads}" && touch "${workloads}/userlocal"; } || die
}

src_install() {
	local dest="opt/dotnet_core"
	dodir "${dest}"

	local ddest="${D}/${dest}"
	cp -a "${S}"/* "${ddest}/" || die
}
