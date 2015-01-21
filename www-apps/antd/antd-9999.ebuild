# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
USE_DOTNET="net45"

inherit git-2 eutils dotnet

DESCRIPTION="Antd"
HOMEPAGE="http://www.anthilla.com/en/projects/antd"
SRC_URI=""

LICENSE="BSD-2" #BSD-3 really...
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="+heather"

if use heather; then
	EGIT_REPO_URI="git://github.com/Heather/Antd.git"
	EGIT_MASTER="heather"
else
	EGIT_REPO_URI="git://github.com/Anthilla/Antd.git"
	EGIT_MASTER="master"
fi

DEPEND=""
RDEPEND="${DEPEND}"

src_prepare() {
	addpredict /etc/mono/registry/last-btime #nowarn
}

src_install() {
	elog "Installing Antd"
	insinto /usr/lib/mono/Antd/
	doins -r Antd/bin/Release/*
	make_wrapper antd "mono /usr/lib/mono/Antd/Antd.exe"
}
