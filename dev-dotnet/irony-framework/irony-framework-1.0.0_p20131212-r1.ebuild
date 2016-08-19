# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
# >=portage-2.2.25

# debug = debug configuration (symbols and defines for debugging)
# developer = generate symbols information (to view line numbers in stack traces, either in debug or release configuration)
# test = allow NUnit tests to run
# nupkg = create .nupkg file from .nuspec
# gac = install into gac
# pkg-config = register in pkg-config database
IUSE="net45 debug developer test +nupkg +gac +pkg-config"
USE_DOTNET="net45"

KEYWORDS="~amd64 ~x86"

inherit versionator vcs-snapshot gac nupkg

NAME=irony
EHG_REVISION=09918247d378a0e3deedae2af563fa5f402530f9
SRC_URI="http://download-codeplex.sec.s-msft.com/Download/SourceControlFileDownload.ashx?ProjectName=${NAME}&changeSetId=${EHG_REVISION}  -> ${PN}-${PV}.zip
	mirror://gentoo/mono.snk.bz2"

SLOT="0"

# /var/tmp/portage/dev-dotnet/irony-framework-1.0.0_p20131212-r1/work/irony_09918247d378a0e3deedae2af563fa5f402530f9
S="${WORKDIR}/${NAME}_${EHG_REVISION}"

METAFILETOBUILD="Irony/010.Irony.2012.csproj"

src_unpack()
{
	default
	# delete untrusted binaries
	find "${S}" -iname "*.exe" -print -delete || die
	find "${S}" -iname "*.dll" -print -delete || die
	# Libraries/FastColoredTextBox/FastColoredTextBox.dll
}

src_prepare() {
	default
	einfo "patching project files"
	eapply "${FILESDIR}/csproj.patch"
	if ! use test ; then
		einfo "removing unit tests from solution"
	fi

	cp "${FILESDIR}/${NUSPEC_FILE_NAME}" "${S}/${NUSPEC_FILE_NAME}" || die
	epatch_nuspec_file "${S}/${NUSPEC_FILE_NAME}"
}

# PR 	Package revision, or r0 if no revision exists.
NUSPEC_VERSION=$(get_version_component_range 1-3)"${PR//r/.}"
ICON_URL=https://raw.githubusercontent.com/ArsenShnurkov/dotnet/irony-framework/dev-dotnet/irony-framework/files/irony.png
NUSPEC_FILE_NAME="Irony.nuspec"
NUSPEC_ID="Irony"

src_compile() {
	exbuild /p:SignAssembly=true "/p:AssemblyOriginatorKeyFile=${WORKDIR}/mono.snk" "${METAFILETOBUILD}"

	# run nuget_pack
	einfo ".nuspec version is ${NUSPEC_VERSION}"
	enuspec -Prop "version=${NUSPEC_VERSION};package_iconUrl=${ICON_URL}" "${S}/${NUSPEC_FILE_NAME}"
	# /var/tmp/portage/dev-dotnet/irony-framework-1.0.0_p20131212-r1/work/Irony.1.0.0.1.nupkg
}

epatch_nuspec_file()
{
	if use nupkg; then
		if use debug; then
			DIR="Debug"
			FILES_STRING=`sed 's/[\/&]/\\\\&/g' <<-EOF || die "escaping replacement string characters"
			  <files> <!-- https://docs.nuget.org/create/nuspec-reference -->
			    <file src="Irony/bin/${DIR}/Irony.dll" target="lib\net45\" />
			    <file src="Irony/bin/${DIR}/Irony.dll.mdb" target="lib\net45\" />
			  </files>
			EOF
			`
		else
			DIR="Release"
			FILES_STRING=`sed 's/[\/&]/\\\\&/g' <<-EOF || die "escaping replacement string characters"
			  <files> <!-- https://docs.nuget.org/create/nuspec-reference -->
			    <file src="Irony/bin/${DIR}/Irony.dll" target="lib\net45\" />
			  </files>
			EOF
			`
		fi
		sed -i 's/<\/package>/'"${FILES_STRING//$'\n'/\\$'\n'}"'\n&/g' $1 || die "escaping line endings"
	fi
}

src_install() {
	enupkg "${WORKDIR}/${NUSPEC_ID}.${NUSPEC_VERSION}.nupkg"

	egacinstall "Irony/bin/${DIR}/Irony.dll"

	install_pc_file
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
			-e 's*@LIBS@*-r:${libdir}'"/mono/${PC_FILE_NAME}/Irony.dll"'*' \
			<<\EOF >"${D}/usr/$(get_libdir)/pkgconfig/${PC_FILE_NAME}.pc" || die
prefix=${pcfiledir}/../..
exec_prefix=${prefix}
libdir=${exec_prefix}/@LIBDIR@
Name: @PACKAGENAME@
Description: @DESCRIPTION@
Version: @VERSION@
Libs: @LIBS@
EOF

		einfo PKG_CONFIG_PATH="${D}/usr/$(get_libdir)/pkgconfig/" pkg-config --exists "${PC_FILE_NAME}"
		PKG_CONFIG_PATH="${D}/usr/$(get_libdir)/pkgconfig/" pkg-config --exists "${PC_FILE_NAME}" || die ".pc file failed to validate."
		eend $?
	fi
}

LICENSE="MIT"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"

RDEPEND="${COMMON_DEPEND}
"

DEPEND="${COMMON_DEPEND}
	test? ( dev-util/nunit:2[nupkg] )
	virtual/pkgconfig
"

HOMEPAGE="https://irony.codeplex.com"
DESCRIPTION="parsing framework for C# on LALR(1)"
