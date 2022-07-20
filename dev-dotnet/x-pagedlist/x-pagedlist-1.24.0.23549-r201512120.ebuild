# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit versionator gac nupkg

HOMEPAGE="https://github.com/kpi-ua/X.PagedList/"
DESCRIPTION="Nugget for easily paging through any IEnumerable/IQueryable in Asp.Net MVC"
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

NAME="X.PagedList"
REPOSITORY="https://github.com/ArsenShnurkov/${NAME}"
EGIT_BRANCH="master"
LICENSE_URL="${REPOSITORY}/blob/${EGIT_BRANCH}/LICENSE"
ICONMETA="https://uxrepo.com/static/icon-sets/iconic/svg/list.svg"
ICON_URL="https://github.com/ArsenShnurkov/X.PagedList/blob/switching-from-pcl/misc/list.svg"

EGIT_COMMIT="48bc7da1bc3b6b294c69796bd9573e670edd3c64"
SRC_URI="${REPOSITORY}/archive/${EGIT_BRANCH}/${EGIT_COMMIT}.zip -> ${PF}.zip
	mirror://gentoo/mono.snk.bz2"
#S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
S="${WORKDIR}/${NAME}-${EGIT_BRANCH}"

METAFILETOBUILD=./src/X.PagedList.sln
#OUTPUT_DIR=

# there is an original file exists: ./src/X.PagedList.Mvc/PagedList.Mvc.nuspec
NUSPEC_FILE_NAME=X.PagedList.nuspec
#NUSPEC_VERSION="${PVR//-r/.}"
NUSPEC_VERSION=$(get_version_component_range 1-3)"${PR//r/.}"

# rm -rf /var/tmp/portage/dev-dotnet/X-PagedList-1.24.0.23549-r201512120
# emerge =X-PagedList-1.24.0.23549-r201512120
# leafpad /var/tmp/portage/dev-dotnet/X-PagedList-1.24.0.23549-r201512120/temp/build.log &

src_unpack()
{
	default
	enuget_download_rogue_binary "Microsoft.Web.Infrastructure" "1.0.0.0"
	enuget_download_rogue_binary "Microsoft.AspNet.WebPages" "3.2.3"
	enuget_download_rogue_binary "Microsoft.AspNet.Razor" "3.2.3"
	enuget_download_rogue_binary "Microsoft.AspNet.Mvc" "5.2.3"
}

src_prepare() {
	einfo "patching project files"
	epatch "${FILESDIR}/X.PagedList.csproj.patch"
	epatch "${FILESDIR}/X.PagedList.Mvc.csproj.patch"

	# no restoring for this particular project for now, see src_unpack() above instead
	# einfo "restoring packages"
	# enuget_restore -Verbosity detailed -SolutionDirectory "${S}" "./src/X.PagedList/packages.config"
	# enuget_restore "./src/X.PagedList.Mvc/X.PagedList.Mvc.csproj"
	# enuget_restore -Verbosity detailed -SolutionDirectory "${S}" "./src/X.PagedList.Mvc/packages.config"

	einfo "preparing nuspec"
	cp "${FILESDIR}/${NUSPEC_FILE_NAME}" "${S}/${NUSPEC_FILE_NAME}" || die
	patch_nuspec_file "${S}/${NUSPEC_FILE_NAME}"

	eapply_user
}

src_configure() {
	:;
}

src_compile() {
	exbuild /p:SignAssembly=true "/p:AssemblyOriginatorKeyFile=${WORKDIR}/mono.snk" "./src/X.PagedList/X.PagedList.csproj"
	exbuild /p:SignAssembly=true "/p:AssemblyOriginatorKeyFile=${WORKDIR}/mono.snk" "./src/X.PagedList.Mvc/X.PagedList.Mvc.csproj"

	# run nuget_pack
	einfo "setting .nupkg version to ${NUSPEC_VERSION}"
	enuspec -Prop "version=${NUSPEC_VERSION}" "${S}/${NUSPEC_FILE_NAME}"
}

src_install() {
	enupkg "${WORKDIR}/${NAME}.${NUSPEC_VERSION}.nupkg"

	egacinstall "src/X.PagedList/bin/${DIR}/X.PagedList.dll"
	egacinstall "src/X.PagedList.Mvc/bin/${DIR}/X.PagedList.Mvc.dll"

	einstall_pc_file "${PN}" "${PV}" "X.PagedList.Mvc"
}

patch_nuspec_file()
{
	if use nupkg; then
		if use debug; then
			DIR="Debug"
			FILES_STRING=`sed 's/[\/&]/\\\\&/g' <<-EOF || die "escaping replacement string characters"
			  <files> <!-- https://docs.nuget.org/create/nuspec-reference -->
			    <file src="src/X.PagedList/bin/${DIR}/X.PagedList.dll" target="lib\net45\" />
			    <file src="src/X.PagedList.Mvc/bin/${DIR}/X.PagedList.Mvc.dll" target="lib\net45\" />
			    <file src="src/X.PagedList/bin/${DIR}/X.PagedList.dll.mdb" target="lib\net45\" />
			    <file src="src/X.PagedList.Mvc/bin/${DIR}/X.PagedList.Mvc.dll.mdb" target="lib\net45\" />
			  </files>
			EOF
			`
		else
			DIR="Release"
			FILES_STRING=`sed 's/[\/&]/\\\\&/g' <<-EOF || die "escaping replacement string characters"
			  <files> <!-- https://docs.nuget.org/create/nuspec-reference -->
			    <file src="src/X.PagedList/bin/${DIR}/X.PagedList.dll" target="lib\net45\" />
			    <file src="src/X.PagedList.Mvc/bin/${DIR}/X.PagedList.Mvc.dll" target="lib\net45\" />
			  </files>
			EOF
			`
		fi

		sed -i 's/<\/package>/'"${FILES_STRING//$'\n'/\\$'\n'}"'\n&/g' $1 || die "escaping line endings"
	fi
}
