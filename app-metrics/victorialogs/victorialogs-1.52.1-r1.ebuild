# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

MY_PN="VictoriaLogs"

DESCRIPTION="Fast and easy-to-use log database from VictoriaMetrics"
HOMEPAGE="https://victoriametrics.com/products/victorialogs/ https://github.com/VictoriaMetrics/VictoriaLogs"
SRC_URI="https://github.com/VictoriaMetrics/${MY_PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${MY_PN}-${PV}"

# Upstream ships vendor/, no go-module tarball needed
LICENSE="Apache-2.0 BSD MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE="+server vlagent +vlogscli"
REQUIRED_USE="|| ( server vlagent vlogscli )"
RESTRICT="test"

ACCT_DEPEND="
	acct-group/victoria-logs
	acct-user/victoria-logs
"
RDEPEND="
	server? ( ${ACCT_DEPEND} )
	vlagent? ( ${ACCT_DEPEND} )
"
BDEPEND=">=dev-lang/go-1.26.5"

src_compile() {
	local buildinfo="github.com/VictoriaMetrics/VictoriaMetrics/lib/buildinfo.Version"
	local app apps=()

	use server && apps+=( victoria-logs )
	use vlagent && apps+=( vlagent )
	use vlogscli && apps+=( vlogscli )

	for app in "${apps[@]}"; do
		ego build -ldflags "-X '${buildinfo}=${app}-tags-v${PV}'" \
			-o bin/${app} ./app/${app}
	done
}

src_install() {
	exeinto /opt/${PN}/bin
	doexe bin/*

	# command line tools
	use vlogscli && dosym -r /opt/${PN}/bin/vlogscli /usr/bin/vlogscli

	# daemons
	if use server; then
		newinitd "${FILESDIR}"/${PN}.2.init ${PN}
		newconfd "${FILESDIR}"/${PN}.1.conf ${PN}
	fi

	if use vlagent; then
		newinitd "${FILESDIR}"/vlagent.1.init vlagent
		newconfd "${FILESDIR}"/vlagent.1.conf vlagent
	fi

	einstalldocs
}

pkg_postinst() {
	local svc svcs=()

	use server && svcs+=( ${PN} )
	use vlagent && svcs+=( vlagent )

	[[ ${#svcs[@]} -eq 0 ]] && return

	for svc in "${svcs[@]}"; do
		elog "Configure ${svc} in /etc/conf.d/${svc}, then:"
		elog "  rc-update add ${svc} default"
		elog "  rc-service ${svc} start"
	done

	if use vlagent; then
		elog "vlagent runs as victoria-logs: files collected with VLAGENT_FILES"
		elog "must be readable by that user (e.g. via ACLs or group permissions)."
	fi
}
