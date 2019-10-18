# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit eutils

DESCRIPTION=".NET Core Runtime - binary precompiled for glibc"
HOMEPAGE="https://www.microsoft.com/net/core"
LICENSE="MIT"

SRC_URI="
amd64? ( https://dotnetcli.blob.core.windows.net/dotnet/Runtime/${PV}/dotnet-runtime-${PV}-linux-x64.tar.gz -> dotnet-runtime-${PV}-linux-x64.tar.gz )
arm? ( https://dotnetcli.blob.core.windows.net/dotnet/Runtime/${PV}/dotnet-runtime-${PV}-linux-arm.tar.gz -> dotnet-runtime-${PV}-linux-arm.tar.gz )
"

SLOT="0"
KEYWORDS="~amd64 ~arm"

# The sdk includes the runtime-bin and aspnet-bin so prevent from installing at the same time

RDEPEND="
	>=sys-apps/lsb-release-1.4
	>=sys-devel/llvm-4.0
	amd64? ( >=dev-util/lldb-4.0 )
	>=sys-libs/libunwind-1.1-r1
	>=dev-libs/icu-57.1
	>=dev-util/lttng-ust-2.8.1
	>=dev-libs/openssl-1.0.2h-r2
	>=net-misc/curl-7.49.0
	>=app-crypt/mit-krb5-1.14.2
	>=sys-libs/zlib-1.2.8-r1
	!dev-dotnet/dotnetcore-sdk
	!dev-dotnet/dotnetcore-sdk-bin"

S=${WORKDIR}

src_install() {
	local dest="opt/dotnet_core"
	dodir "${dest}"

	local ddest="${D}${dest}"
	cp -a "${S}"/* "${ddest}/" || die
	dosym "/${dest}/dotnet" "/usr/bin/dotnet"
}
