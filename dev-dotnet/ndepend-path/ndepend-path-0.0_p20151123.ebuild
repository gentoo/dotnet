# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

KEYWORDS="~amd64"
RESTRICT="mirror"

SLOT="0"

IUSE="debug"
USE_DOTNET="net40"

inherit dotnet gac mpt-r20150903

DESCRIPTION="C# framework for paths operations: Absolute, Drive Letter, UNC, Relative, prefix"
LICENSE="MIT"
NAME="NDepend.Path"
HOMEPAGE="https://github.com/psmacchia/${NAME}"
EGIT_COMMIT="96008fcfbc137eac6fd327387b80b14909a581a1"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

CDEPEND="|| ( >=dev-lang/mono-4 <dev-lang/mono-9999 )"
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}"

DLLNAME=${NAME}
FULLSLN=${NAME}.sln

src_prepare() {
	empt-csproj --dir="${S}/${NAME}" --remove-reference "Microsoft.Contracts"
	empt-sln --sln-file "${S}/${FULLSLN}" --remove-proj "NDepend.Path.Tests"
	eapply_user
}

src_compile() {
	exbuild_strong "${FULLSLN}"
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	elog "Installing ${DLLNAME}.dll into GAC "
	egacinstall "${NAME}/bin/${DIR}/${DLLNAME}.dll"
}
