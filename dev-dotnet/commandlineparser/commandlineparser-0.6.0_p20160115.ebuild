# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6 # >=portage-2.2.25

inherit versionator

KEYWORDS="~amd64"

USE_DOTNET="net45"
# debug = debug configuration (symbols and defines for debugging)
# developer = generate symbols information (to view line numbers in stack traces, either in debug or release configuration)
# test = allow NUnit tests to run
# nupkg = create .nupkg file from .nuspec
# gac = install into gac
# pkg-config = register in pkg-config database
IUSE="${USE_DOTNET} debug test +developer +aot +nupkg +gac +pkg-config"

inherit gac nupkg versionator

HOMEPAGE="https://github.com/mgrosperrin/commandlineparser/releases"
DESCRIPTION="command line parser on System.ComponentModel.DataAnnotations"
LICENSE="MIT"
LICENSE_URL="https://raw.githubusercontent.com/mgrosperrin/commandlineparser/master/LICENSE"

SLOT="0"

# to unpack archive
REPOSITORY_NAME="commandlineparser"
REPOSITORY_URL="https://github.com/ArsenShnurkov/${REPOSITORY_NAME}"
EGIT_COMMIT="2203477397a68885fdf004ae4eb2300a2d271347"
SRC_URI="${REPOSITORY_URL}/archive/${EGIT_COMMIT}.zip -> ${P}.zip
	mirror://gentoo/mono.snk.bz2"
S="${WORKDIR}/${REPOSITORY_NAME}-${EGIT_COMMIT}"

COMMON_DEPENDENCIES="|| ( >=dev-lang/mono-4.2 <dev-lang/mono-9999 )"
RDEPEND="${COMMON_DEPENDENCIES}
"
DEPEND="${COMMON_DEPENDENCIES}
"

METAFILETOBUILD=MGR.CommandLineParser.linux.sln

NUSPEC_FILENAME="commandlineparser.nuspec"
NUSPEC_ID="${REPOSITORY_NAME}"
COMMIT_DATE_INDEX=$(get_version_component_count ${PV} )
COMMIT_DATE=$(get_version_component_range $COMMIT_DATE_INDEX ${PV} )
NUSPEC_VERSION=$(get_version_component_range 1-3)"${COMMIT_DATE//p/.}${PR//r/}"
ICON_FILENAME=commandlineparser.png
ICON_FINALNAME=${NUSPEC_ID}.${NUSPEC_VERSION}.png
ICON_PATH=$(get_nuget_trusted_icons_location)/${ICON_FINALNAME}

# https://devmanual.gentoo.org/ebuild-writing/functions/pkg_setup/
# https://devmanual.gentoo.org/ebuild-writing/functions/index.html
# pkg_setup is executed before both - src_unpack (for source ebuilds) and pkg_preinst (for binary ebuilds)
pkg_setup() {
	addwrite "/usr/share/.mono/keypairs"
	mozroots --import --sync --machine

	# some kind of "default" from "detnet.eclass"
	# https://github.com/gentoo/dotnet/blob/master/eclass/dotnet.eclass#L42-L78
	dotnet_pkg_setup
}

src_unpack()
{
	default
	# delete untrusted executables
	find "${S}" -iname "*.exe" -delete || die
	find "${S}" -iname "*.dll" -delete || die
}

src_prepare() {
	# TODO: disable package restore in .csproj file
	# see https://bartwullems.blogspot.ru/2012/08/disable-nuget-package-restore.html

	# replace package versions in projects
	# for example 2.6.2 -> 2.6.4 (for NUnit)

	# prepare nuspec file
	elog "${S}/${NUSPEC_FILENAME}"
	cp "${FILESDIR}/${NUSPEC_FILENAME}" "${S}/${NUSPEC_FILENAME}" || die
	patch_nuspec_file "${S}/${NUSPEC_FILENAME}"

	# restore dependencies from local repository
	# EnableNuGetPackageRestore somehow implied to be used by exbuild
	# export EnableNuGetPackageRestore="true"
	enuget_restore "${METAFILETOBUILD}"

	# prepare sources for signing
	if use gac; then
		find . -iname "*.csproj" -print0 | xargs -0 \
		sed -i 's/<DefineConstants>/<DefineConstants>SIGNED;/g' || die
		#PUBLIC_KEY=`sn -q -p ${SNK_FILENAME} /dev/stdout | hexdump -e '"%02x"'`
		#find . -iname "AssemblyInfo.cs" -print0 | xargs -0 sed -i "s/PublicKey=[0-9a-fA-F]*/PublicKey=${PUBLIC_KEY}/g" || die
		find . -iname "AssemblyInfo.cs" -print0 | xargs -0 sed -i "/InternalsVisibleTo/d" || die
	fi

	if !use test ; then
		: ; # todo: remove tests from solution
	fi

	# apply user patches
	default
}

src_configure() {
	default
}

# rm -rf /var/tmp/portage/dev-dotnet/commandlineparser-0.6.0-p20160115 && emerge =commandlineparser-0.6.0-p20160115
src_compile() {
	exbuild /p:SignAssembly=true "/p:AssemblyOriginatorKeyFile=${WORKDIR}/mono.snk" "${METAFILETOBUILD}"

	NUSPEC_PROPS+="nuget_version=${NUSPEC_VERSION};"
	NUSPEC_PROPS+="nuget_id=${NUSPEC_ID};"
	NUSPEC_PROPS+="nuget_projectUrl=${HOMEPAGE};"
	NUSPEC_PROPS+="nuget_licenseUrl=${LICENSE_URL};"
	NUSPEC_PROPS+="nuget_description=${DESCRIPTION};"
	NUSPEC_PROPS+="nuget_iconUrl=file://${ICON_PATH}"
	elog "NUSPEC_PROPS=${NUSPEC_PROPS}"
	enuspec -Prop "${NUSPEC_PROPS}" "${S}/${NUSPEC_FILENAME}"

	if use aot; then
		if use debug; then
			DIR="Debug"
		else
			DIR="Release"
		fi
		# Could not load file or assembly or one of its dependencies.
		# assembly:NuGet.Core, Version=2.8.7.0, Culture=neutral, PublicKeyToken=null type:<unknown type> member:<none>.
		# Run with MONO_LOG_LEVEL=debug for more information.
		einfo 'mono --aot -O=all "src/MGR.CommandLineParser/obj/${DIR}/MGR.CommandLineParser.dll"'
		mono --aot -O=all "src/MGR.CommandLineParser/obj/${DIR}/MGR.CommandLineParser.dll" || die
	fi
}

src_test() {
	default
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	#/usr/bin/nunit264 "${S}/src/MGR.CommandLineParser.Tests/obj/${DIR}/MGR.CommandLineParser.Tests.dll" || die
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	#nongac install
	#insinto "/usr/$(get_libdir)/${PN}/"
	#doins src/MGR.CommandLineParser/obj/${DIR}/MGR.CommandLineParser.dll
	#if use developer; then
	#	"doins src/MGR.CommandLineParser/obj/${DIR}/MGR.CommandLineParser.dll.mdb"
	#fi

	# gac install
	if use gac; then
		# Failure adding assembly src/Core/bin/Release/NuGet.Core.dll to the cache: Attempt to install an assembly without a strong name
		elog "Installing MGR.CommandLineParser.dll into GAC"
		egacinstall "src/MGR.CommandLineParser/obj/${DIR}/MGR.CommandLineParser.dll"
	fi

	# local package install
	if use nupkg; then
		enupkg "${WORKDIR}/${NUSPEC_ID}.${NUSPEC_VERSION}.nupkg"
		insinto /var/calculate/remote/packages/NuGet/icons/
		# newins - Install a miscellaneous file using the second argument as the name.
		newins "${FILESDIR}/${ICON_FILENAME}" "${ICON_FINALNAME}"
	fi

	# Copy the AOT compilation result
	if use aot; then
		einfo "Copy the AOT compilation result"
		insinto "/usr/$(get_libdir)/${PN}/"
		doins "src/MGR.CommandLineParser/obj/${DIR}/MGR.CommandLineParser.dll.so"
	fi

	einstall_pc_file "${PN}" "0.6" "MGR.CommandLineParser"
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
		    <file src="src/MGR.CommandLineParser/bin/${DIR}/MGR.CommandLineParser.*" target="lib\net45\" />
		  </files>
		EOF
		`
		sed -i 's/<\/package>/'"${FILES_STRING//$'\n'/\\$'\n'}"'\n&/g' $1 || die "escaping line endings"
	fi
}
