# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="A user for app-metrics/victorialogs"
ACCT_USER_ID=666
ACCT_USER_HOME=/var/lib/victoria-logs
ACCT_USER_HOME_PERMS=0750
ACCT_USER_GROUPS=( victoria-logs )

acct-user_add_deps
