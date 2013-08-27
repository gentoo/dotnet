# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

USE_DOTNET="net40"
NUGET_NO_DEPEND="1"

inherit nuget dotnet eutils

DESCRIPTION="FAKE - F# Make"
HOMEPAGE="http://nuget.org/packages/FAKE"

SRC_URI="https://github.com/fsharp/FAKE/archive/${NPV}.tar.gz"

LICENSE="MS-PL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="-nuget"

DEPEND="dev-lang/mono
	dev-lang/fsharp
	nuget? ( dev-dotnet/nuget )"

RDEPEND="${DEPEND}"

src_unpack() {
	if use nuget ; then
		echo "using nuget"
		nuget_src_unpack
	else
		default;
		S=${WORKDIR}/FAKE-${NPV}
	fi
}

src_compile() {
	if use nuget ; then
		echo "installation is done via nuget"
	else
		#fake is searching for libraries in source folder
		ln -s tools/FAKE/tools/Newtonsoft.Json.dll "${S}"/Newtonsoft.Json.dll || die
		ln -s tools/FAKE/tools/NuGet.Core.dll "${S}"/NuGet.Core.dll || die
		ln -s tools/FAKE/tools/Fake.SQL.dll "${S}"/Fake.SQL.dll || die
		sh "${S}/build.sh" || die "build.sh failed"
	fi
}

src_install() {
	elog "Installing libraries"
	insinto /usr/lib/mono/FAKE/"${FRAMEWORK}"/
	if use nuget ; then
		doins FAKE."${NPV}"/tools/FAKE.exe
		doins FAKE."${NPV}"/tools/FakeLib.dll
		nonfatal doins FAKE."${NPV}"/tools/Newtonsoft.Json.dll
		nonfatal doins FAKE."${NPV}"/tools/Fake.SQL.dll
		nonfatal doins FAKE."${NPV}"/tools/NuGet.Core.dll
	else
		doins build/FAKE.exe
		doins build/FakeLib.dll
		nonfatal doins tools/FAKE/tools/Newtonsoft.Json.dll
		nonfatal doins tools/FAKE/tools/Fake.SQL.dll
		nonfatal doins tools/FAKE/tools/NuGet.Core.dll
	fi
	make_wrapper fake "mono /usr/lib/mono/FAKE/${FRAMEWORK}/FAKE.exe \"\$@\""
}
