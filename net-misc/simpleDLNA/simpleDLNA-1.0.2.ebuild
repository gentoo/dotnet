# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit dotnet eutils

DESCRIPTION="A simple, zero-config DLNA media server, just fire up and be done with it."
HOMEPAGE="https://github.com/nmaier/${PN}"
SRC_URI="https://github.com/nmaier/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

# Need patched version until upstream merges https://github.com/nmaier/simpleDLNA/pull/29
# I tried to epatch locally, but it chokes on mixed line endings (some LF, some CRLF)
SRC_URI="https://github.com/piedar/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-2" # simpleDLNA, GetOptNet
LICENSE+=" MIT" # Microsoft.IO.RecyclableMemoryStream
LICENSE+=" Apache-2.0" # log4net
LICENSE+=" LGPL-2.1" # taglib
LICENSE+=" public-domain" # System.Data.SQLite.Core

KEYWORDS="~amd64 ~x86"
SLOT="0"

USE_DOTNET="net45" # todo: necessary?
IUSE="${USE_DOTNET} debug developer"

COMMON_DEPEND=">=dev-lang/mono-4.4.1"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND} dev-dotnet/nuget"

src_prepare() {
	# use system nuget
	sed -i 's|mono .* "$(NuGetExePath)"|nuget|g' .nuget/NuGet.targets || die

	default
}

APPS="sdlna SimpleDLNA"

src_compile() {
	for APP in ${APPS}; do
		exbuild "${APP}/${APP}".csproj
	done
}

src_install() {
	einstalldocs

	use debug && BINDIR="bin/Debug" || BINDIR="bin/Release"
	DESTDIR="/usr/lib/mono/${P}"

	for APP in ${APPS}; do
		insinto "${DESTDIR}"
		doins "${APP}/${BINDIR}"/*

		mkdir -p shells || die
		echo \
"#!/bin/sh
exec mono ${DESTDIR}/${APP}.exe \"\$@\"" > shells/"${APP}"
		dobin shells/"${APP}"
	done
}
