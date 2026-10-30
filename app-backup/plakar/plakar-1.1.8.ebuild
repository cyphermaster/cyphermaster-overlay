# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Backup tool with deduplication, encryption and a built-in snapshot browser"
HOMEPAGE="https://plakar.io https://github.com/PlakarKorp/plakar"
# The deps tarball holds the output of "go mod vendor" (${P}/vendor/).
SRC_URI="
	https://github.com/PlakarKorp/plakar/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/cyphermaster/overlay/releases/download/${P}/${P}-deps.tar.xz
"

LICENSE="ISC"
# Dependent licenses
LICENSE+=" Apache-2.0 BSD BSD-2 CC0-1.0 ISC MIT MPL-2.0 Unlicense"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND=">=dev-lang/go-1.26.10:="

src_compile() {
	ego build -trimpath -o ${PN} .
}

src_test() {
	# Upstream test bugs in 1.1.8: api tests do not build, cached
	# hangs in TestRebuildStateVersionMismatch, and
	# TestBackupMultipleIgnoreFileFlags expects a removed .DS_Store default.
	local pkgs
	pkgs=$(ego list ./... | grep -v -e '/api$' -e '/cached$') || die
	ego test -skip TestBackupMultipleIgnoreFileFlags ${pkgs}
}

src_install() {
	dobin ${PN}
	doman $(find . -path ./vendor -prune -o -name '*.[157]' -print || die)
	einstalldocs
}
