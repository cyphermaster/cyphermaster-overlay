# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

MY_PN="VictoriaMetrics"

DESCRIPTION="Fast, cost-effective and scalable time series database and monitoring solution"
HOMEPAGE="https://victoriametrics.com/ https://github.com/VictoriaMetrics/VictoriaMetrics"
SRC_URI="https://github.com/VictoriaMetrics/${MY_PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${MY_PN}-${PV}"

# Upstream ships vendor/, no go-module tarball needed
LICENSE="Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0"
SLOT="0"
KEYWORDS="amd64"
IUSE="+server backup vmagent vmalert vmauth vmctl"
REQUIRED_USE="|| ( server backup vmagent vmalert vmauth vmctl )"
RESTRICT="test"

ACCT_DEPEND="
	acct-group/victoria-metrics
	acct-user/victoria-metrics
"
RDEPEND="
	server? ( ${ACCT_DEPEND} )
	vmagent? ( ${ACCT_DEPEND} )
	vmalert? ( ${ACCT_DEPEND} )
	vmauth? ( ${ACCT_DEPEND} )
"
# vmauth.yml is installed group-owned by victoria-metrics
DEPEND="vmauth? ( ${ACCT_DEPEND} )"
BDEPEND=">=dev-lang/go-1.26.5"

src_compile() {
	local buildinfo="github.com/VictoriaMetrics/VictoriaMetrics/lib/buildinfo.Version"
	local app apps=()

	use server && apps+=( victoria-metrics )
	use backup && apps+=( vmbackup vmrestore )
	use vmagent && apps+=( vmagent )
	use vmalert && apps+=( vmalert vmalert-tool )
	use vmauth && apps+=( vmauth )
	use vmctl && apps+=( vmctl )

	for app in "${apps[@]}"; do
		ego build -ldflags "-X '${buildinfo}=${app}-tags-v${PV}'" \
			-o bin/${app} ./app/${app}
	done
}

src_install() {
	exeinto /opt/${PN}/bin
	doexe bin/*

	# command line tools
	local tool
	for tool in vmbackup vmrestore vmalert-tool vmctl; do
		[[ -e bin/${tool} ]] && dosym -r /opt/${PN}/bin/${tool} /usr/bin/${tool}
	done

	# daemons
	if use server; then
		newinitd "${FILESDIR}"/${PN}.1.init ${PN}
		newconfd "${FILESDIR}"/${PN}.1.conf ${PN}
	fi

	if use vmagent; then
		newinitd "${FILESDIR}"/vmagent.1.init vmagent
		newconfd "${FILESDIR}"/vmagent.1.conf vmagent
		insinto /etc/victoria-metrics
		newins "${FILESDIR}"/vmagent.1.yml vmagent.yml
	fi
	if use vmalert; then
		newinitd "${FILESDIR}"/vmalert.1.init vmalert
		newconfd "${FILESDIR}"/vmalert.1.conf vmalert
		insinto /etc/victoria-metrics/vmalert
		newins "${FILESDIR}"/vmalert-rules.1.yml rules.yml
	fi
	if use vmauth; then
		newinitd "${FILESDIR}"/vmauth.1.init vmauth
		newconfd "${FILESDIR}"/vmauth.1.conf vmauth
		insinto /etc/victoria-metrics
		insopts -m 0640 -g victoria-metrics
		newins "${FILESDIR}"/vmauth.1.yml vmauth.yml
		insopts -m 0644
	fi

	einstalldocs
}

pkg_postinst() {
	local svc svcs=()

	use server && svcs+=( ${PN} )
	use vmagent && svcs+=( vmagent )
	use vmalert && svcs+=( vmalert )
	use vmauth && svcs+=( vmauth )

	[[ ${#svcs[@]} -eq 0 ]] && return

	for svc in "${svcs[@]}"; do
		elog "Configure ${svc} in /etc/conf.d/${svc}, then:"
		elog "  rc-update add ${svc} default"
		elog "  rc-service ${svc} start"
	done

	use vmagent && elog "vmagent scrape config: /etc/victoria-metrics/vmagent.yml"
	use vmalert && elog "vmalert rules: /etc/victoria-metrics/vmalert/*.yml"
	use vmauth && elog "vmauth config: /etc/victoria-metrics/vmauth.yml"
}
