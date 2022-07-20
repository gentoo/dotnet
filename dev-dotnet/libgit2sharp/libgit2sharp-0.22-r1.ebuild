# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KEYWORDS="~amd64"
RESTRICT+=" mirror"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET}"
EBUILD_FRAMEWORK="4.5"

inherit gac nupkg

DESCRIPTION="A C# PInvoke wrapper library for LibGit2 C library"

REPO_OWNER=libgit2
NAME=libgit2sharp
EGIT_COMMIT="8daef23223e1374141bf496e4b310ded9ae4639e"
HOMEPAGE="https://github.com/${REPO_OWNER}/${NAME}"
SRC_URI="https://api.github.com/repos/${REPO_OWNER}/${NAME}/tarball/${EGIT_COMMIT} -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${REPO_OWNER}-${NAME}-8daef23"

LICENSE="MIT"
SLOT="0"

CDEPEND=">=dev-lang/mono-4.9.0.729-r2
	dev-libs/libgit2
"

DEPEND="${CDEPEND}
	dev-dotnet/nuget
"
RDEPEND="${CDEPEND}"

prefix=${PREFIX}/usr
exec_prefix=${prefix}
libdir=${exec_prefix}/lib/mono/${EBUILD_FRAMEWORK}

NUSPEC_FILE="nuget.package/LibGit2Sharp.nuspec"

src_unpack() {
	default
	# remove rogue binaries
	rm -rf "${S}/Lib/NuGet/" || die
	rm -rf "${S}/Lib/CustomBuildTasks/CustomBuildTasks.dll" || die
}

src_prepare() {
	eapply "${FILESDIR}/sln.patch"
	eapply "${FILESDIR}/csproj-remove-nuget-targets-check.patch"
	eapply "${FILESDIR}/packages-config-remove-xunit.patch"
	eapply "${FILESDIR}/remove-NativeBinaries-package-dependency.patch"
	eapply "${FILESDIR}/nuspec-file-list.patch"
	echo "/usr/lib64/libgit2.so" >"LibGit2Sharp/libgit2_filename.txt" || die
	enuget_restore "LibGit2Sharp.sln"
	sed -i 's=\$id\$=LibGit2Sharp=g' "${NUSPEC_FILE}" || die
	sed -i "s=\\\$version\\\$=$(get_version_component_range 1-2)=g" "${NUSPEC_FILE}" || die
	sed -i 's=\$author\$=nulltoken=g' "${NUSPEC_FILE}" || die
	sed -i "s=\\\$description\\\$=${DESCRIPTION}=g" "${NUSPEC_FILE}" || die
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	sed -i "s=\\\$configuration\\\$=${DIR}=g" "${NUSPEC_FILE}" || die
	default
}

src_compile() {
	# recreate custom build tasks .dll
	sed -i "s#<OutputPath>.*</OutputPath>#<OutputPath>.</OutputPath>#g" "Lib/CustomBuildTasks/CustomBuildTasks.csproj" || die
	exbuild "Lib/CustomBuildTasks/CustomBuildTasks.csproj"

	# main compilation
	exbuild_strong "LibGit2Sharp.sln"

	enuspec "${NUSPEC_FILE}"
}

src_install() {
	insinto "${libdir}"
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	doins "LibGit2Sharp/bin/${DIR}/LibGit2Sharp.dll"

	enupkg "${WORKDIR}/LibGit2Sharp.0.22.nupkg"
}

pkg_postinst() {
	if use gac; then
		einfo "adding to GAC"
		gacutil -i "${libdir}/LibGit2Sharp.dll" || die
	fi

	# cd "${WORKDIR}
	# nuget push -source "Local NuGet packages" LibGit2Sharp.0.22.nupkg
}

pkg_postrm() {
	if use gac; then
		einfo "removing from GAC"
		gacutil -u LibGit2Sharp
		# don't die, it there is no such assembly in GAC
	fi

	# yes | nuget delete -source "Local NuGet packages" LibGit2Sharp 0.22
}
