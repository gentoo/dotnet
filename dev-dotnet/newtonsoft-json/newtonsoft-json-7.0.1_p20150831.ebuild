# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# debug = debug configuration (symbols and defines for debugging)
# developer = generate symbols information (to view line numbers in stack traces, either in debug or release configuration)
# test = allow NUnit tests to run
# nupkg = create .nupkg file from .nuspec
# gac = install into gac
# pkg-config = register in pkg-config database
USE_DOTNET="net45"
IUSE="${USE_DOTNET} debug developer test +nupkg +gac +pkg-config"

inherit nupkg gac

NAME="Newtonsoft.Json"
NUSPEC_ID="${NAME}"
HOMEPAGE="https://github.com/JamesNK/${NAME}"

EGIT_COMMIT="05710874cd61adabfb635085b1b45cf31882df3d"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${P}.zip
	https://github.com/mono/mono/raw/master/mcs/class/mono.snk"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="0"

DESCRIPTION="Json.NET is a popular high-performance JSON framework for .NET"
LICENSE="MIT"
LICENSE_URL="https://raw.github.com/JamesNK/Newtonsoft.Json/master/LICENSE.md"

KEYWORDS="~amd64 ~x86"
COMMON_DEPENDENCIES="|| ( >=dev-lang/mono-4.2 <dev-lang/mono-9999 )"
RDEPEND="${COMMON_DEPENDENCIES}
"
DEPEND="${COMMON_DEPENDENCIES}
	dev-util/nunit:2[nupkg]
"

METAFILETOBUILD=Src/Newtonsoft.Json.sln

NUSPEC_FILENAME="Newtonsoft.Json.nuspec"
COMMIT_DATE_INDEX=$(get_version_component_count ${PV} )
COMMIT_DATE=$(get_version_component_range $COMMIT_DATE_INDEX ${PV} )
NUSPEC_VERSION=$(get_version_component_range 1-3)"${COMMIT_DATE//p/.}${PR//r/}"

ICON_FILENAME=nugeticon.png
ICON_URL=$(get_nuget_trusted_icons_location)/${NUSPEC_ID}.${NUSPEC_VERSION}.png

src_prepare() {
	elog "${S}/${NUSPEC_FILENAME}"

	# replace 2.6.2 -> 2.6.4 (for NUnit)
	egrep -lRZ '2\.6\.2' "${S}" | xargs -0 sed -i 's/2\.6\.2/2\.6\.4/g'  || die

	enuget_restore "${METAFILETOBUILD}"
	# Installing 'Autofac 3.5.0'.
	# Installing 'NUnit 2.6.2'.
	# Installing 'System.Collections.Immutable 1.1.36'.
	# Installing 'FSharp.Core 4.0.0'.
	eapply "${FILESDIR}/removing-tests.patch"

	if use gac; then
		find . -iname "*.csproj" -print0 | xargs -0 \
		sed -i 's/<DefineConstants>/<DefineConstants>SIGNED;/g' || die
		#PUBLIC_KEY=`sn -q -p ${SNK_FILENAME} /dev/stdout | hexdump -e '"%02x"'`
		#find . -iname "AssemblyInfo.cs" -print0 | xargs -0 sed -i "s/PublicKey=[0-9a-fA-F]*/PublicKey=${PUBLIC_KEY}/g" || die
		find . -iname "AssemblyInfo.cs" -print0 | xargs -0 sed -i "/InternalsVisibleTo/d" || die
	fi

	cp "${FILESDIR}/${NUSPEC_FILENAME}" "${S}/${NUSPEC_FILENAME}" || die
	patch_nuspec_file "${S}/${NUSPEC_FILENAME}"

	default
}

src_compile() {
	exbuild /p:SignAssembly=true "/p:AssemblyOriginatorKeyFile=${WORKDIR}/mono.snk" "${METAFILETOBUILD}"

	NUSPEC_PROPS+="nuget_version=${NUSPEC_VERSION};"
	NUSPEC_PROPS+="nuget_id=${NUSPEC_ID};"
	NUSPEC_PROPS+="nuget_projectUrl=${HOMEPAGE};"
	NUSPEC_PROPS+="nuget_licenseUrl=${LICENSE_URL};"
	NUSPEC_PROPS+="nuget_description=${DESCRIPTION};"
	NUSPEC_PROPS+="nuget_iconUrl=file://${ICON_URL}"
	elog "NUSPEC_PROPS=${NUSPEC_PROPS}"
	enuspec -Prop "${NUSPEC_PROPS}" "${S}/${NUSPEC_FILENAME}"
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	FINAL_DLL=Src/Newtonsoft.Json/bin/${DIR}/Net45/Newtonsoft.Json.dll

	if use gac; then
		egacinstall "${FINAL_DLL}"
	fi

	insinto "$(get_nuget_trusted_icons_location)"
	newins "${FILESDIR}/${ICON_FILENAME}" "${NUSPEC_ID}.${NUSPEC_VERSION}.png"

	enupkg "${WORKDIR}/${NUSPEC_ID}.${NUSPEC_VERSION}.nupkg"

	einstall_pc_file "${PN}" "7.0" "${NAME}"
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
		    <file src="Src/Newtonsoft.Json/bin/${DIR}/Net45/Newtonsoft.Json.*" target="lib\net45\" />
		  </files>
		EOF
		`
		sed -i 's/<\/package>/'"${FILES_STRING//$'\n'/\\$'\n'}"'\n&/g' $1 || die "escaping line endings"
	fi
}
