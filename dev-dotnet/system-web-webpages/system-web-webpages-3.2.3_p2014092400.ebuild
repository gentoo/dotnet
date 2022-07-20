# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mono-env gac nupkg versionator

REPO_NAME="aspnetwebstack"
HOMEPAGE="https://github.com/ASP-NET-MVC/aspnetwebstack"

EGIT_BRANCH="master"
EGIT_COMMIT="4e40cdef9c8a8226685f95ef03b746bc8322aa92"
SRC_URI="${HOMEPAGE}/archive/${EGIT_BRANCH}/${EGIT_COMMIT}.tar.gz -> ${REPO_NAME}-${EGIT_COMMIT}.tar.gz"
RESTRICT="mirror"
#S="${WORKDIR}/${REPO_NAME}-${EGIT_COMMIT}"
S="${WORKDIR}/${REPO_NAME}-${EGIT_BRANCH}"

SLOT="0"

DESCRIPTION="parser and code generation infrastructure for Razor markup syntax"
LICENSE="Apache-2.0"
KEYWORDS="~amd64"
#USE_DOTNET="net45 net40 net20"
USE_DOTNET="net45"

IUSE="+${USE_DOTNET} developer debug"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
	dev-dotnet/system-web-razor
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

DLL_NAME=System.Web.WebPages
DLL_PATH=bin
FILE_TO_BUILD=./src/${DLL_NAME}/${DLL_NAME}.csproj
METAFILETOBUILD="${S}/${FILE_TO_BUILD}"

NUSPEC_ID=Microsoft.AspNet.WebPages

COMMIT_DATE_INDEX="$(get_version_component_count ${PV} )"
COMMIT_DATE="$(get_version_component_range $COMMIT_DATE_INDEX ${PV} )"
NUSPEC_VERSION=$(get_version_component_range 1-3)"${COMMIT_DATE//p/.}"

src_prepare() {
	cp "${FILESDIR}/${NUSPEC_ID}.nuspec" "${S}" || die
	chmod -R +rw "${S}" || die
	patch_nuspec_file "${S}/${NUSPEC_ID}.nuspec"
	eapply "${FILESDIR}/remove-DataVisualiztion.patch"
	eapply "${FILESDIR}/disable-warning-as-error.patch"
	eapply_user
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
		    <file src="${DLL_PATH}/${DIR}/${DLL_NAME}.*" target="lib/net45/" />
		    <file src="${DLL_PATH}/${DIR}/System.Web.WebPages.Deployment.*" target="lib/net45/" />
		    <file src="${DLL_PATH}/${DIR}/System.Web.Helpers.*" target="lib/net45/" />
		  </files>
		EOF
		`
		sed -i 's/<\/package>/'"${FILES_STRING//$'\n'/\\$'\n'}"'\n&/g' $1 || die "escaping line endings"
	fi
}

src_compile() {
	exbuild "${METAFILETOBUILD}"
	exbuild "${S}/src/System.Web.Helpers/System.Web.Helpers.csproj"

	sn -R "${DLL_PATH}/${DIR}/System.Web.WebPages.dll" /var/lib/layman/dotnet/eclass/mono.snk || die
	sn -R "${DLL_PATH}/${DIR}/System.Web.WebPages.Deployment.dll" /var/lib/layman/dotnet/eclass/mono.snk || die
	sn -R "${DLL_PATH}/${DIR}/System.Web.Helpers.dll" /var/lib/layman/dotnet/eclass/mono.snk || die

	einfo nuspec: "${S}/${NUSPEC_ID}.nuspec"
	einfo nupkg: "${WORKDIR}/${NUSPEC_ID}.${NUSPEC_VERSION}.nupkg"

	enuspec -Prop BuildVersion=${NUSPEC_VERSION} "${S}/${NUSPEC_ID}.nuspec"
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	egacinstall "${DLL_PATH}/${DIR}/${DLL_NAME}.dll"
	egacinstall "${DLL_PATH}/${DIR}/System.Web.WebPages.Deployment.dll"
	egacinstall "${DLL_PATH}/${DIR}/System.Web.Helpers.dll"

	enupkg "${WORKDIR}/${NUSPEC_ID}.${NUSPEC_VERSION}.nupkg"
}
