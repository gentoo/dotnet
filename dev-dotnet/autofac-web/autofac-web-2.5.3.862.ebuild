# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

KEYWORDS="~amd64"
RESTRICT="mirror"

SLOT="2"
if [ "${SLOT}" != "0" ]; then
    APPENDIX="-${SLOT}"
fi

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +debug developer doc"

inherit versionator msbuild gac mono-pkg-config

GITHUB_REPONAME="Autofac"
HOMEPAGE="https://github.com/autofac/Autofac.Web"
DESCRIPTION="An addictive .NET IoC container"
LICENSE="MIT" # https://github.com/autofac/Autofac/blob/develop/LICENSE

EGIT_COMMIT="5ad2d85df4e99d3588589d89874672856ba7b60e"
PV4="$(get_version_component_range 1-4)"
TARBALL_EXT=".tar.gz"
SRC_URI="https://github.com/autofac/${GITHUB_REPONAME}/archive/${EGIT_COMMIT}${TARBALL_EXT} -> ${GITHUB_REPONAME}-${PV4}${TARBALL_EXT}
	https://github.com/mono/mono/raw/main/mcs/class/mono.snk"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	dev-dotnet/autofac:2
"

KEY2="${DISTDIR}/mono.snk"

function project_relpath() {
	echo "Core/Source/Autofac.Integration.Web"
}

function output_filename() {
	echo "$(project_relpath)/$(output_relpath)/Autofac.Integration.Web.dll"
}

src_prepare() {
	dotnet_pkg_setup
	sed -i '/MSBuildCommunityTasksPath/d' "${S}/default.proj" || die
	emsbuild /p:AssemblyVersion=${PV} /t:UpdateVersion "${S}/default.proj"
	eapply_user
}

src_compile() {
	emsbuild "/p:SignAssembly=true" "/p:PublicSign=true" "/p:AssemblyOriginatorKeyFile=${KEY2}" /p:VersionNumber=${PV} "$(project_relpath)/Autofac.Integration.Web.csproj"
	sn -R "$(output_filename)" "${KEY2}" || die
}

src_install() {
	egacinstall "$(output_filename)"
	einstall_pc_file "${PN}" "${PV}" "Autofac.Integration.Web"
}
