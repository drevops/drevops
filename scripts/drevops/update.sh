#!/usr/bin/env bash
##
# Update DrevOps.
#

set -e
[ -n "${DREVOPS_DEBUG}" ] && set -x

# The URL of the installer script.
export DREVOPS_INSTALLER_URL="${DREVOPS_INSTALLER_URL:-https://install.drevops.com}"

# Allow providing custom DrevOps commit hash to download the sources from.
export DREVOPS_INSTALL_COMMIT="${DREVOPS_INSTALL_COMMIT:-}"

# ------------------------------------------------------------------------------

curl -L "${DREVOPS_INSTALLER_URL}"?"$(date +%s)" > /tmp/install.php && php /tmp/install.php --quiet; rm /tmp/install.php;

