# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
KEYWORDS="~amd64"
RESTRICT="mirror"

USE_DOTNET="net45"
IUSE="net45 +gac +nupkg +pkg-config debug developer"

inherit versionator gac nupkg

HOMEPAGE="https://github.com/kpi-ua/X.PagedList/"
DESCRIPTION="Nugget for easily paging through any IEnumerable/IQueryable in Asp.Net MVC"
LICENSE="MIT"
SLOT="0"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"

DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
	>=dev-util/mono-packaging-tools-1.4.2.2
"

RDEPEND="${COMMON_DEPEND}
"

NAME="X.PagedList"
REPOSITORY="https://github.com/ArsenShnurkov/${NAME}"
EGIT_BRANCH="master"
LICENSE_URL="${REPOSITORY}/blob/${EGIT_BRANCH}/LICENSE"
ICONMETA="https://uxrepo.com/static/icon-sets/iconic/svg/list.svg"
ICON_URL="https://github.com/ArsenShnurkov/X.PagedList/blob/switching-from-pcl/misc/list.svg"

EGIT_COMMIT="c0521a4099c65efd3e964ea57129d5a61261f784"
SRC_URI="${REPOSITORY}/archive/${EGIT_BRANCH}/${EGIT_COMMIT}.tar.gz -> ${PF}.tar.gz"
#S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
S="${WORKDIR}/${NAME}-${EGIT_BRANCH}"

METAFILETOBUILD=./X.PagedList.sln
#OUTPUT_DIR=

# there is an original file exists: ./src/X.PagedList.Mvc/PagedList.Mvc.nuspec
NUSPEC_FILE_NAME=X.PagedList.nuspec
NUSPEC_VERSION="${PV}"

# rm -rf /var/tmp/portage/dev-dotnet/X-PagedList-*
# emerge =X-PagedList-5.3.0.8
# leafpad /var/tmp/portage/dev-dotnet/X-PagedList-5.3.0.8/temp/build.log &

src_prepare() {
	einfo "patching project files"

	find "${S}" -iname "AssemblyInfo.cs" -exec sed -i '/Assembly.*Version/d' {} \; || die
	mpt-csproj --inject-import='$(MSBuildToolsPath)\MSBuild.Community.Tasks.Targets' "${S}" || die
	mpt-csproj --inject-versioning=BuildVersion "${S}" || die

	einfo "preparing nuspec"
	cp "${FILESDIR}/${NUSPEC_FILE_NAME}" "${S}/${NUSPEC_FILE_NAME}" || die
	patch_nuspec_file "${S}/${NUSPEC_FILE_NAME}"

	eapply_user
}

src_configure() {
	:;
}

SNK_FILENAME="${S}/X.PagedList/PublicPrivateKeyFile.snk"

src_compile() {
	exbuild_strong /p:BuildVersion=${PV} "./X.PagedList/X.PagedList.csproj"
	exbuild_strong /p:BuildVersion=${PV} "./X.PagedList.Mvc/X.PagedList.Mvc.csproj"

	# run nuget_pack
	einfo "setting .nupkg version to ${NUSPEC_VERSION}"
	enuspec -Prop "version=${NUSPEC_VERSION}" "${S}/${NUSPEC_FILE_NAME}"
}

src_install() {
	enupkg "${WORKDIR}/${NAME}.${NUSPEC_VERSION}.nupkg"

	egacinstall "X.PagedList/bin/${DIR}/X.PagedList.dll"
	egacinstall "X.PagedList.Mvc/bin/${DIR}/X.PagedList.Mvc.dll"

	einstall_pc_file "${PN}" "${PV}" "X.PagedList.Mvc"
}

patch_nuspec_file()
{
	if use nupkg; then
		if use debug; then
			DIR="Debug"
			FILES_STRING=`sed 's/[\/&]/\\\\&/g' <<-EOF || die "escaping replacement string characters"
			  <files> <!-- https://docs.nuget.org/create/nuspec-reference -->
			    <file src="X.PagedList/bin/${DIR}/X.PagedList.dll" target="lib/net45" />
			    <file src="X.PagedList.Mvc/bin/${DIR}/X.PagedList.Mvc.dll" target="lib/net45" />
			    <file src="X.PagedList/bin/${DIR}/X.PagedList.dll.mdb" target="lib/net45" />
			    <file src="X.PagedList.Mvc/bin/${DIR}/X.PagedList.Mvc.dll.mdb" target="lib/net45" />
			  </files>
			EOF
			`
		else
			DIR="Release"
			FILES_STRING=`sed 's/[\/&]/\\\\&/g' <<-EOF || die "escaping replacement string characters"
			  <files> <!-- https://docs.nuget.org/create/nuspec-reference -->
			    <file src="X.PagedList/bin/${DIR}/X.PagedList.dll" target="lib\net45" />
			    <file src="X.PagedList.Mvc/bin/${DIR}/X.PagedList.Mvc.dll" target="lib\net45" />
			  </files>
			EOF
			`
		fi

		sed -i 's/<\/package>/'"${FILES_STRING//$'\n'/\\$'\n'}"'\n&/g' $1 || die "escaping line endings"
	fi
}
