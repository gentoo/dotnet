# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KEYWORDS="~amd64"
RESTRICT="mirror"

SLOT="1"
if [ "${SLOT}" != "0" ]; then
    APPENDIX="-${SLOT}"
fi

USE_DOTNET="net45"

inherit versionator dotnet msbuild

IUSE="+${USE_DOTNET} +debug developer +msbuild +xbuild +symlink"

HOMEPAGE="https://github.com/loresoft/msbuildtasks"
EGIT_COMMIT="abaab03d71fc07b020a860f6d407f6814cb0f6d5"
TARBALL_FILENAME="${PN}-$(get_version_component_range 1-4)"
TARBALL_EXT=".tar.gz"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}${TARBALL_EXT} -> ${TARBALL_FILENAME}${TARBALL_EXT}
	https://github.com/mono/mono/raw/main/mcs/class/mono.snk"
GITHUB_REPONAME="msbuildtasks"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

DESCRIPTION="The MSBuild Community Tasks Project is an open source project for MSBuild tasks."
LICENSE="BSD" # https://github.com/loresoft/msbuildtasks/blob/master/LICENSE

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
	>=dev-dotnet/dotnetzip-semverd-1.9.3-r2
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

KEY2="${DISTDIR}/mono.snk"

function project_relpath ( ) {
	echo "Source/MSBuild.Community.Tasks"
}

function metafile_to_build ( ) {
	echo "$(project_relpath)/MSBuild.Community.Tasks.csproj"
}

function AssemblyName ( ) {
	echo "MSBuild.Community.Tasks"
}

function targets_filename ( ) {
	echo "MSBuild.Community.Tasks.Targets"
}

function deploy_dir ( ) {
	echo "/usr/lib/mono/${EBUILD_FRAMEWORK}/MSBuild.Community.Tasks${APPENDIX}"
}

src_prepare() {
	dotnet_pkg_setup # in particular it calculates value of EBUILD_FRAMEWORK variable, which is used in install phase
	eapply "${FILESDIR}/remove-sandcastle-task.patch"
	eapply "${FILESDIR}/csproj.patch"
	eapply "${FILESDIR}/location.patch"
	sed -i "s?/usr/lib/mono/4.5?/usr/lib/mono/4.5/MSBuild.Community.Tasks${APPENDIX}?g" "${S}/$(project_relpath)/$(targets_filename)" || die
	sed -i 's/Microsoft.Build.Framework/Microsoft.Build.Framework, Version=15.3.0.0, Culture=neutral, PublicKeyToken=0738eb9f132ed756/g' "$(metafile_to_build)" || die
	sed -i 's/Microsoft.Build.Utilities.v4.0/Microsoft.Build.Utilities.Core, Version=15.3.0.0, Culture=neutral, PublicKeyToken=0738eb9f132ed756/g' "$(metafile_to_build)" || die
	eapply_user
}

src_compile() {
	emsbuild "/p:SignAssembly=true" "/p:PublicSign=true" "/p:AssemblyOriginatorKeyFile=${KEY2}" "$(metafile_to_build)"
	sn -R "$(project_relpath)/$(output_relpath)/$(AssemblyName).dll" "${KEY2}" || die
}

src_install() {
	insinto "$(deploy_dir)"
	doins "$(project_relpath)/$(output_relpath)/$(AssemblyName).dll"
	doins "$(project_relpath)/$(targets_filename)"

	if use msbuild && use symlink; then
		dosym "$(deploy_dir)" "${EPREFIX}/usr/share/msbuild/MSBuildCommunityTasks"
	fi

	if use xbuild && use symlink; then
		dosym "$(deploy_dir)" "${EPREFIX}/usr/lib/mono/xbuild/MSBuildCommunityTasks"
	fi
}
