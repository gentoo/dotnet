# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

USE_DOTNET="net40"

inherit nuget dotnet

DESCRIPTION="FAKE - F# Make"
HOMEPAGE="http://nuget.org/packages/FAKE"

SRC_URI="https://github.com/fsharp/FAKE/archive/${NPV}.tar.gz"

LICENSE="MS-PL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="-nuget"

DEPEND="dev-lang/mono
dev-lang/fsharp"
RDEPEND="${DEPEND}"

src_unpack() {
	if use nuget ; then
		echo "using nuget"
		nuget_src_unpack;
	else
		default;
		S=${WORKDIR}/FAKE-${NPV}
	fi
}

src_prepare() {
	if use nuget ; then
		echo "installation is done via nuget"
	else
		#fake is searching for libraries in source folder
		ln -s tools/FAKE/tools/Newtonsoft.Json.dll "${S}"/Newtonsoft.Json.dll
		ln -s tools/FAKE/tools/NuGet.Core.dll "${S}"/NuGet.Core.dll
		ln -s tools/FAKE/tools/Fake.SQL.dll "${S}"/Fake.SQL.dll
		sh "${S}/build.sh"
	fi
}

src_install() {
	elog "Installing libraries"
	insinto /usr/lib/mono/FAKE/"${FRAMEWORK}"/
	if use nuget ; then
		doins FAKE."${NPV}"/tools/FAKE.exe || die
		doins FAKE."${NPV}"/tools/FakeLib.dll || die
		doins FAKE."${NPV}"/tools/Newtonsoft.Json.dll
		doins FAKE."${NPV}"/tools/Fake.SQL.dll
		doins FAKE."${NPV}"/tools/NuGet.Core.dll
	else
		doins build/FAKE.exe || die
		doins build/FakeLib.dll || die
		doins tools/FAKE/tools/Newtonsoft.Json.dll
		doins tools/FAKE/tools/Fake.SQL.dll
		doins tools/FAKE/tools/NuGet.Core.dll
	fi
}

pkg_postinst() {
	#Exec :
	echo "mono /usr/lib/mono/FAKE/${FRAMEWORK}/FAKE.exe \"\$@\"" > /usr/bin/fake
	chmod 777 /usr/bin/fake
}
