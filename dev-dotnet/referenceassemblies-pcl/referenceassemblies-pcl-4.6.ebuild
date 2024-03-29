# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit rpm

HOMEPAGE="https://developer.xamarin.com/guides/cross-platform/application_fundamentals/pcl/"
DESCRIPTION=".NET Portable Class Library reference assemblies"
SRC_URI="https://download.mono-project.com/repo/centos/r/referenceassemblies-pcl/referenceassemblies-pcl-${PV}-0.noarch.rpm"
# https://www.microsoft.com/net/dotnet_library_license.htm
# https://www.microsoft.com/web/webpi/eula/net_library_eula_enu.htm
LICENSE="TODO"

SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=dev-lang/mono-4.0"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_install() {
	cp -R "${S}/"* "${D}/" || die "Install failed!"
}
