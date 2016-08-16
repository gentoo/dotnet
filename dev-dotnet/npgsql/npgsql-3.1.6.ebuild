# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

# debug = debug configuration (symbols and defines for debugging)
# developer = generate symbols information (to view line numbers in stack traces, either in debug or release configuration)
# test = allow NUnit tests to run
# nupkg = create .nupkg file from .nuspec
# gac = install into gac
# pkg-config = register in pkg-config database
USE_DOTNET="net45"
IUSE="${USE_DOTNET} debug developer test +nupkg +gac +pkg-config"

inherit nupkg

NAME="npgsql"
NUSPEC_ID="${NAME}"
HOMEPAGE="https://github.com/npgsql/${NAME}"

EGIT_COMMIT="a7e147759c3756b6d22f07f5602aacd21f93d48d"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz
	gac? ( mirror://gentoo/mono.snk.bz2 )"
RESTRICT="mirror"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="0"

DESCRIPTION="allows any program developed for .NET framework to access a PostgreSQL database"
LICENSE="npgsql"
LICENSE_URL="https://github.com/npgsql/npgsql/blob/develop/LICENSE.txt"

KEYWORDS="~amd64 ~ppc ~x86"
COMMON_DEPENDENCIES="|| ( >=dev-lang/mono-4.2 <dev-lang/mono-9999 )
	nupkg? ( dev-util/nunit )
"
RDEPEND="${COMMON_DEPENDENCIES}
"
DEPEND="${COMMON_DEPENDENCIES}
	nupkg? ( dev-util/nunit:2[nupkg] )
	!nupkg? ( dev-util/nunit:2 )
"

NPGSQL_CSPROJ=src/Npgsql/Npgsql.csproj
METAFILETOBUILD=${NPGSQL_CSPROJ}

NUSPEC_FILENAME="npgsql.nuspec"
COMMIT_DATE_INDEX=$(get_version_component_count ${PV} )
COMMIT_DATE=$(get_version_component_range $COMMIT_DATE_INDEX ${PV} )
NUSPEC_VERSION=$(get_version_component_range 1-3)"${COMMIT_DATE//p/.}${PR//r/}"

ICON_FILENAME=postgresql-header.png
#ICON_URL=http://www.npgsql.org/css/img/postgresql-header.png
ICON_URL=$(get_nuget_trusted_icons_location)/${NUSPEC_ID}.${NUSPEC_VERSION}.png

src_unpack() {
	# Installing 'NLog 3.2.0.0'.
	# Installing 'AsyncRewriter 0.6.0'.
	# Installing 'EntityFramework 5.0.0'.
	# Installing 'EntityFramework 6.1.3'.
	# Installing 'NUnit 2.6.4'.
	enuget_download_rogue_binary "NLog" "3.2.0.0"
	enuget_download_rogue_binary "AsyncRewriter" "0.6.0"
	enuget_download_rogue_binary "EntityFramework" "5.0.0"
	enuget_download_rogue_binary "EntityFramework" "6.1.3"
	#enuget_download_rogue_binary "NUnit" "2.6.4"
	default
}

src_prepare() {
	elog "${S}/${NUSPEC_FILENAME}"

	enuget_restore "${METAFILETOBUILD}"

	cp "${FILESDIR}/${NUSPEC_FILENAME}" "${S}/${NUSPEC_FILENAME}" || die
	patch_nuspec_file "${S}/${NUSPEC_FILENAME}"

	default
}

src_compile() {
	#exbuild /t:RewriteAsync "${NPGSQL_CSPROJ}"
	exbuild /p:SignAssembly=true "/p:AssemblyOriginatorKeyFile=${WORKDIR}/mono.snk" "${METAFILETOBUILD}"
	if use test; then
		exbuild /p:SignAssembly=true "/p:AssemblyOriginatorKeyFile=${WORKDIR}/mono.snk" "test/Npgsql.Tests/Npgsql.Tests.csproj"
	fi

	NUSPEC_PROPS+="nuget_version=${NUSPEC_VERSION};"
	NUSPEC_PROPS+="nuget_id=${NUSPEC_ID};"
	NUSPEC_PROPS+="nuget_projectUrl=${HOMEPAGE};"
	NUSPEC_PROPS+="nuget_licenseUrl=${LICENSE_URL};"
	NUSPEC_PROPS+="nuget_description=${DESCRIPTION};"
	NUSPEC_PROPS+="nuget_iconUrl=file://${ICON_URL}"
	elog "NUSPEC_PROPS=${NUSPEC_PROPS}"
	enuspec -Prop "${NUSPEC_PROPS}" "${S}/${NUSPEC_FILENAME}"
}

src_test() {
	default
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	FINAL_DLL=src/Npgsql/bin/${DIR}/Npgsql.dll

	if use gac; then
		egacinstall "${FINAL_DLL}"
	fi

	insinto "$(get_nuget_trusted_icons_location)"
	newins "${FILESDIR}/${ICON_FILENAME}" "${NUSPEC_ID}.${NUSPEC_VERSION}.png"

	enupkg "${WORKDIR}/${NUSPEC_ID}.${NUSPEC_VERSION}.nupkg"

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
FILES_STRING=`cat <<-EOF || die "${DIR} files at patch_nuspec_file()"
	<files> <!-- https://docs.nuget.org/create/nuspec-reference -->
		<file src="src/Npgsql/bin/${DIR}/Npgsql.dll" target="lib\net45\" />
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
			-e 's*@LIBS@*-r:${libdir}'"/mono/${PC_FILE_NAME}/npgsql.dll"'*' \
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
