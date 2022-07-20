# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
KEYWORDS="~amd64"

RESTRICT="mirror"

SLOT="0"
if [ "${SLOT}" != "0" ]; then
	APPENDIX="-${SLOT}"
fi

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} developer nupkg debug"

inherit versionator xbuild nupkg

HOMEPAGE="https://github.com/nant/${NAME}"
DESCRIPTION=".NET build tool"
LICENSE="GPL-2"

EGIT_COMMIT="e3644541bf083d8e33f450bfbd1a4147e494769c"
EGIT_BRANCH="master"
GITHUBNAME="nant/nant"
GITHUBACC=${GITHUBNAME%/*}
GITHUBREPO=${GITHUBNAME#*/}
GITFILENAME=${GITHUBREPO}-${GITHUBACC}-${PV}-${EGIT_COMMIT}
GITHUB_ZIP="https://api.github.com/repos/${GITHUBACC}/${GITHUBREPO}/zipball/${EGIT_COMMIT} -> ${GITFILENAME}.zip"
SRC_URI="${GITHUB_ZIP}"
S="${WORKDIR}/${GITFILENAME}"

RDEPEND=">=dev-lang/mono-4.4.0.40
	!dev-dotnet/nant
	nupkg? ( dev-dotnet/nuget )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

SLN_FILE=NAnt.sln
METAFILETOBUILD="${S}/${SLN_FILE}"

# This build is not parallel build friendly
#MAKEOPTS="${MAKEOPTS} -j1"

src_unpack() {
	default_src_unpack
	mv "${WORKDIR}/${GITHUBACC}-${GITHUBREPO}-"* "${WORKDIR}/${GITFILENAME}" || die
}

src_prepare() {
	dotnet_pkg_setup
	find ${S} -type f -iname "*.csproj" -exec sed -i "s/Microsoft.CSharp.Targets/Microsoft.CSharp.targets/g" {} \; || die
	eapply_user
}

src_compile() {
	exbuild "${METAFILETOBUILD}"
	enuspec "${FILESDIR}/${SLN_FILE}.nuspec"
}

src_install() {
	DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	insinto "/usr/share/nant/"
	doins build/${DIR}/*

	make_wrapper nant "mono /usr/share/nant/NAnt.exe"

	enupkg "${WORKDIR}/NAnt.0.93.5019.nupkg"

	dodoc README.txt
}
