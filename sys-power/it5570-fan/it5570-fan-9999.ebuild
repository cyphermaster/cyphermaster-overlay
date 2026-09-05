# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit git-r3 linux-mod-r1
DESCRIPTION="Linux hwmon driver for ITE IT5570E Embedded Controller (fans/temps)"
HOMEPAGE="https://github.com/passiveEndeavour/it5570-fan"
EGIT_REPO_URI="https://github.com/passiveEndeavour/it5570-fan.git"


LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

CONFIG_CHECK="HWMON"

src_compile() {
	local modlist=( it5570_fan=: )
	local modargs=( KSRC="${KV_OUT_DIR}" )
	linux-mod-r1_src_compile
}

src_install() {
	linux-mod-r1_src_install
	dodoc README.md
}
