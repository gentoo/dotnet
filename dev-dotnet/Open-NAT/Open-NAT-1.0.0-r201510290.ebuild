# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

# mono-env
inherit  dotnet nupkg

HOMEPAGE="https://lontivero.github.io/Open.NAT"
DESCRIPTION="Class library to use port forwarding in NAT devices with UPNP and/or PMP"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
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

	install_pc_file
}

patch_nuspec_file()
{
	if use nupkg; then
		if use debug; then
			DIR="Debug"
		else
			DIR="Release"
		fi
		FILES_STRING=`cat <<-EOF || die "files at patch_nuspec_file()"
		       <files> <!-- https://docs.nuget.org/create/nuspec-reference -->
		               <file src="${OUTPUT_DIR}/${DIR}/*.dll" target="lib\net45\" />
		               <file src="${OUTPUT_DIR}/${DIR}/*.mdb" target="lib\net45\" />
		       </files>
		EOF
		`
		einfo ${FILES_STRING}
		replace "</package>" "${FILES_STRING}</package>" -- $1 || die "replace at patch_nuspec_file()"
	fi
}

PC_FILE_NAME=${PN}

install_pc_file()
{
	if use pkg-config; then
		dodir /usr/$(get_libdir)/pkgconfig
		ebegin "Installing ${PC_FILE_NAME}.pc file"
		sed \
			-e "s:@LIBDIR@:$(get_libdir):" \
			-e "s:@PACKAGENAME@:${PC_FILE_NAME}:" \
			-e "s:@DESCRIPTION@:${DESCRIPTION}:" \
			-e "s:@VERSION@:${PV}:" \
			-e 's;@LIBS@;-r:${libdir}'"/mono/${PC_FILE_NAME}/${GAC_DLL_NAME}.dll;" \
			<<\EOF >"${D}/usr/$(get_libdir)/pkgconfig/${PC_FILE_NAME}.pc" || die
prefix=${pcfiledir}/../..
exec_prefix=${prefix}
libdir=${exec_prefix}/@LIBDIR@

Name: @PACKAGENAME@
Description: @DESCRIPTION@
Version: @VERSION@
Libs: @LIBS@
EOF
# Package exported to: /var/tmp/portage/dev-dotnet/Open-NAT-1.0.0-r201510290/image//usr/lib64/mono/Open-NAT/Open.Nat.dll -> ../gac/Open.Nat/1.0.0.0__0738eb9f132ed756/Open.Nat.dll
# Installed Open.Nat/bin/Release/Open.Nat.dll into the gac (/var/tmp/portage/dev-dotnet/Open-NAT-1.0.0-r201510290/image//usr/lib64/mono/gac)

		einfo PKG_CONFIG_PATH="${D}/usr/$(get_libdir)/pkgconfig/" pkg-config --exists "${PC_FILE_NAME}"
		PKG_CONFIG_PATH="${D}/usr/$(get_libdir)/pkgconfig/" pkg-config --exists "${PC_FILE_NAME}" || die ".pc file failed to validate."
		eend $?
	fi
}
