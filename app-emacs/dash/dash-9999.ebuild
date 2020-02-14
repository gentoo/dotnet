# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit git-r3 elisp

DESCRIPTION="A modern list api for Emacs. No 'cl required."
HOMEPAGE="https://github.com/magnars/dash.el"
EGIT_REPO_URI="git://github.com/magnars/dash.el.git"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"

src_unpack() {
	git-2_src_unpack
	elisp_src_unpack
}
