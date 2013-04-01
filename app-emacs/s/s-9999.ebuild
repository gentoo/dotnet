# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/python-mode/python-mode-6.1.0.ebuild,v 1.1 2013/01/04 10:50:38 fauli Exp $

EAPI=4

inherit git-2 elisp

DESCRIPTION="The long lost Emacs string manipulation library"
HOMEPAGE="https://github.com/magnars/s.el"
EGIT_REPO_URI="git://github.com/magnars/s.el.git"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"

src_unpack() {
	git-2_src_unpack
	elisp_src_unpack
}