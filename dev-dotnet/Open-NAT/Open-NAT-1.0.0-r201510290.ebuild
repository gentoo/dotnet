# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit gac nupkg

HOMEPAGE="https://lontivero.github.io/Open.NAT"
DESCRIPTION="Class library to use port forwarding in NAT devices with UPNP and/or PMP"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="net45 +gac +nupkg +pkg-config debug developer"
USE_DOTNET="net45"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"

RDEPEND="${COMMON_DEPEND}
"

DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"

NAME="Open.NAT"
REPOSITORY="https://github.com/ArsenShnurkov/${NAME}"
LICENSE_URL="${REPOSITORY}/blob/master/LICENSE"
ICONMETA="https://github.com/lontivero/Open.NAT/tree/gh-pages/images/logos"
ICON_URL="https://raw.githubusercontent.com/lontivero/Open.NAT/gh-pages/images/logos/256.jpg"

EGIT_BRANCH="gentoo-mono4"
EGIT_COMMIT="8b1120fa0f2d457fa2c703718bbf3ce079ac5aae"
SRC_URI="${REPOSITORY}/archive/${EGIT_BRANCH}/${EGIT_COMMIT}.zip -> ${PF}.zip
	mirror://gentoo/mono.snk.bz2"
#S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
S="${WORKDIR}/${NAME}-${EGIT_BRANCH}"

#METAFILETOBUILD="./Open.Nat.sln"
METAFILETOBUILD="./Open.Nat/Open.Nat.csproj"

OUTPUT_DIR=Open.Nat/bin
GAC_DLL_NAME=Open.Nat

NUSPEC_FILE="${S}/Open.Nat/Open.Nat.nuspec"
NUSPEC_VERSION="${PVR//-r/.}"

src_prepare() {
	enuget_restore "${METAFILETOBUILD}"

	patch_nuspec_file ${NUSPEC_FILE}

	eapply_user
}

src_configure() {
	:;
}

src_compile() {
	exbuild /p:SignAssembly=true "/p:AssemblyOriginatorKeyFile=${WORKDIR}/mono.snk" "${METAFILETOBUILD}"

	# run nuget_pack
	enuspec -Prop version=${NUSPEC_VERSION} ${NUSPEC_FILE}
}

src_install() {
	enupkg "${WORKDIR}/${NAME}.${NUSPEC_VERSION}.nupkg"

	egacinstall "${OUTPUT_DIR}/${DIR}/${GAC_DLL_NAME}.dll"

	einstall_pc_file "${PN}" "1.0" "${GAC_DLL_NAME}"
}

patch_nuspec_file()
{
	if use nupkg; then
		if use debug; then
			DIR="Debug"
		else
			DIR="Release"
		fi
		FILES_STRING=`sed 's/[\/&]/\\\\&/g' <<-EOF || die "escaping replacement string characters"
		  <files> <!-- https://docs.nuget.org/create/nuspec-reference -->
		    <file src="${OUTPUT_DIR}/${DIR}/*.dll" target="lib\net45\" />
		    <file src="${OUTPUT_DIR}/${DIR}/*.mdb" target="lib\net45\" />
		  </files>
		EOF
		`
		sed -i 's/<\/package>/'"${FILES_STRING//$'\n'/\\$'\n'}"'\n&/g' $1 || die "escaping line endings"
	fi
}
