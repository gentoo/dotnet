# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
# >=portage-2.2.25

# debug = debug configuration (symbols and defines for debugging)
# developer = generate symbols information (to view line numbers in stack traces, either in debug or release configuration)
# test = allow NUnit tests to run
# nupkg = create .nupkg file from .nuspec
# gac = install into gac
# pkg-config = register in pkg-config database
USE_DOTNET="net45"
IUSE="net45 debug +developer test +nupkg +gac +pkg-config"

KEYWORDS="~amd64"

inherit versionator gac nupkg

HOMEPAGE=https://github.com/deveel/irony
NAME=irony
EGIT_COMMIT=7bc3f3e70af5bdd6a095ba06de31e0929751b48e
# P	Package name and version (excluding revision, if any), for example vim-6.3.
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${P}.zip
	mirror://gentoo/mono.snk.bz2"

SLOT="0"

S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

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
ICON_URL=https://raw.githubusercontent.com/ArsenShnurkov/dotnet/deveeldb/dev-dotnet/${PN}/files/deveel-irony.png
NUSPEC_FILE_NAME="Irony.nuspec"
NUSPEC_ID="deveel-irony"

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
FILES_STRING=`cat <<-EOF || die "${DIR} files at patch_nuspec_file()"
	<files> <!-- https://docs.nuget.org/create/nuspec-reference -->
		<file src="Irony/bin/${DIR}/Irony.dll" target="lib\net45\" />
		<file src="Irony/bin/${DIR}/Irony.dll.mdb" target="lib\net45\" />
	</files>
EOF
`
	else
		DIR="Release"
FILES_STRING=`cat <<-EOF || die "${DIR} files at patch_nuspec_file()"
	<files> <!-- https://docs.nuget.org/create/nuspec-reference -->
		<file src="Irony/bin/${DIR}/Irony.dll" target="lib\net45\" />
	</files>
EOF
`
		fi

		einfo ${FILES_STRING}
		sed -i 's#</package>#${FILES_STRING}</package>#' $1 || die "replace at patch_nuspec_file()"
	fi
}

src_install() {
	enupkg "${WORKDIR}/${NUSPEC_ID}.${NUSPEC_VERSION}.nupkg"

	egacinstall "Irony/bin/${DIR}/Irony.dll"

	einstall_pc_file "${PN}" "1.0" "Irony"
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

DESCRIPTION="parsing framework for C# on LALR(1)"
