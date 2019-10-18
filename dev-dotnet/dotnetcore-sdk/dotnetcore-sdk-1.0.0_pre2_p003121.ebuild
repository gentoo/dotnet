# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

#BASED ON https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=dotnet-cli

EAPI="6"

BASE_PV=${PV%_p*}
P_BUILD=${PV##*_p}
DIST='debian-x64'

MY_BASE_PV=${BASE_PV/_pre/-preview}

MY_PV=${MY_BASE_PV}-${P_BUILD}
MY_P=${PN}-${MY_PV}

CORE_V=${PV%%_*}

CORECLR_N=coreclr-${CORE_V}
COREFX_N=corefx-${CORE_V}

DESCRIPTION=".NET Core cli utility for building, testing, packaging and running projects"
HOMEPAGE="https://www.microsoft.com/net/core"
LICENSE="MIT"

IUSE=""
SRC_URI="https://github.com/dotnet/coreclr/archive/v${CORE_V}.tar.gz -> ${CORECLR_N}.tar.gz
	https://github.com/dotnet/corefx/archive/v${CORE_V}.tar.gz -> ${COREFX_N}.tar.gz
	https://download.microsoft.com/download/1/5/2/1523EBE1-3764-4328-8961-D1BD8ECA9295/dotnet-dev-${DIST}.${MY_PV}.tar.gz"

SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=sys-devel/llvm-3.7.1-r3[lldb]
	>=sys-libs/libunwind-1.1-r1
	>=dev-libs/icu-57.1
	>=dev-util/lttng-ust-2.8.1
	>=dev-libs/openssl-1.0.2h-r2
	>=net-misc/curl-7.49.0
	>=app-crypt/mit-krb5-1.14.2"
DEPEND="${RDEPEND}
	>=dev-util/cmake-3.3.1-r1
	>=sys-devel/make-4.1-r1
	>=sys-devel/clang-3.7.1-r100
	>=sys-devel/gettext-0.19.7
	!dev-dotnet/dotnetcore-runtime-bin
	!dev-dotnet/dotnetcore-sdk-bin
	!dev-dotnet/dotnetcore-aspnet-bin"

PATCHES=(
	"${FILESDIR}/${CORECLR_N}-icu57-commit-352df35.patch"
	"${FILESDIR}/${CORECLR_N}-gcc6-github-pull-5304.patch"
	"${FILESDIR}/${CORECLR_N}-segv-github-pull-6027.patch"
)

S=${WORKDIR}
CLI_S="${S}/dotnet_cli"
CORECLR_S="${S}/${CORECLR_N}"
COREFX_S="${S}/${COREFX_N}"

CORECLR_FILES=(
	'libclrjit.so'
	'libcoreclr.so'
	'libcoreclrtraceptprovider.so'
	'libdbgshim.so'
	'libmscordaccore.so'
	'libmscordbi.so'
	'libsos.so'
	'libsosplugin.so'
	'System.Globalization.Native.so'
)

COREFX_FILES=(
	'System.IO.Compression.Native.so'
	'System.Native.a'
	'System.Native.so'
	'System.Net.Http.Native.so'
	'System.Net.Security.Native.so'
	'System.Security.Cryptography.Native.so'
)

src_unpack() {
	unpack "${CORECLR_N}.tar.gz" "${COREFX_N}.tar.gz"
	mkdir "${CLI_S}" || die
	cd "${CLI_S}" || die
	unpack "dotnet-dev-${DIST}.${MY_PV}.tar.gz"
}

src_prepare() {
	for file in "${CORECLR_FILES[@]}"; do
		rm "${CLI_S}/shared/Microsoft.NETCore.App/${CORE_V}/${file}"
	done
	for file in "${COREFX_FILES[@]}"; do
		rm "${CLI_S}/shared/Microsoft.NETCore.App/${CORE_V}/${file}"
	done
	default_src_prepare
}

src_compile() {
	cd "${S}/${CORECLR_N}" || die
	./build.sh x64 release || die

	cd "${S}/${COREFX_N}" || die
	./build.sh native x64 release || die
}

src_install() {
	local dest="/opt/dotnet_cli"
	local ddest="${D}/${dest}"
	local ddest_core="${ddest}/shared/Microsoft.NETCore.App/${CORE_V}/"

	dodir "${dest}"
	cp -pPR "${CLI_S}"/* "${ddest}" || die

	for file in "${CORECLR_FILES[@]}"; do
		cp -pP "${CORECLR_S}/bin/Product/Linux.x64.Release/${file}" "${ddest_core}" || die
	done

	for file in "${COREFX_FILES[@]}"; do
		cp -pP "${COREFX_N}/bin/Linux.x64.Release/Native/${file}" "${ddest_core}" || die
	done

	dosym "../../opt/dotnet_cli/dotnet" "/usr/bin/dotnet"

}
