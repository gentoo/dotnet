# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit eutils

DESCRIPTION=".NET Core SDK - binary precompiled for glibc"
HOMEPAGE="https://www.microsoft.com/net/core"
LICENSE="MIT"

SRC_URI="
amd64? ( https://download.microsoft.com/download/2/E/C/2EC018A0-A0FC-40A2-849D-AA692F68349E/dotnet-sdk-${PV}-linux-x64.tar.gz -> dotnet-sdk-${PV}-linux-x64.tar.gz )
"

SLOT="0"
KEYWORDS="~amd64"

# The sdk includes the runtime-bin and aspnet-bin so prevent from installing at the same time
# dotnetcore-sdk is the source based build

RDEPEND="
	>=sys-apps/lsb-release-1.4
	>=sys-devel/llvm-4.0
	>=dev-util/lldb-4.0
	>=sys-libs/libunwind-1.1-r1
	>=dev-libs/icu-57.1
	>=dev-util/lttng-ust-2.8.1
	>=dev-libs/openssl-1.0.2h-r2
	>=net-misc/curl-7.49.0
	>=app-crypt/mit-krb5-1.14.2
	>=sys-libs/zlib-1.2.8-r1
	!dev-dotnet/dotnetcore-sdk
	!dev-dotnet/dotnetcore-runtime-bin
	!dev-dotnet/dotnetcore-aspnet-bin"

S=${WORKDIR}

src_install() {
	local dest="opt/dotnet_core"
	dodir "${dest}"

	local ddest="${D}${dest}"
	cp -a "${S}"/* "${ddest}/" || die
	dosym "/${dest}/dotnet" "/usr/bin/dotnet"
}
