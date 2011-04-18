# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit base mono

MY_PN="MSBuild.Community.Tasks"

DESCRIPTION="A collection of open source tasks for MSBuild."
HOMEPAGE="http://msbuildtasks.tigris.org/"
SRC_URI="http://${PN}.tigris.org/files/documents/3383/36642/${MY_PN}.v${PV}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-lang/mono"
RDEPEND="${DEPEND}"

S="${WORKDIR}"
#/usr/lib/mono/xbuild

PATCHES=( "${FILESDIR}/${P}-build.patch" )

src_prepare() {
	#rm -v Libraries/nunit.framework.dll || die
	rm -R *uild
	#Maybe one day
	#ln -s "/usr/$(get_libdir)/mono/2.0/nunit.framework.dll" \
	#	Libraries/nunit.framework.dll || die

	base_src_prepare
}

src_compile() {
	xbuild /p:withILMerge=false /p:withIIS=false /p:withSqlServer=false \
		/p:admin=false /p:nunitPath=/usr/lib64/mono/2.0/ \
		/t:Build MSBuildTasks.proj
}

src_install() {
	local ins_dir="/usr/$(get_libdir)/mono/xbuild/"
	dodir "${ins_dir}"
	insinto "${ins_dir}"
	doins build/Debug/bin/MSBuild.Community.Tasks.dll
	newins build/Debug/bin/MSBuild.Community.Tasks.Targets \
		MSBuild.Community.Tasks.targets
}


