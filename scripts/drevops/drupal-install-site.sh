#!/usr/bin/env bash
# shellcheck disable=SC2086
##
# Install site from canonical database.
#

set -e
[ -n "${DREVOPS_DEBUG}" ] && set -x

# Path to the application.
APP="${APP:-/app}"

# Path to the DOCROOT.
WEBROOT="${WEBROOT:-docroot}"

# Drush alias.
DRUSH_ALIAS="${DRUSH_ALIAS:-}"

# Drupal custom module prefix.
# If provided, the ${DRUPAL_MODULE_PREFIX}_core will be enabled (if exists).
DRUPAL_MODULE_PREFIX="${DRUPAL_MODULE_PREFIX:-}"

# Drupal site name
DRUPAL_SITE_NAME="${DRUPAL_SITE_NAME:-Example site}"

# Profile machine name.
DRUPAL_PROFILE="${DRUPAL_PROFILE:-standard}"

# Path to configuration directory.
DRUPAL_CONFIG_PATH="${DRUPAL_CONFIG_PATH:-config/default}"

# Path to private files.
DRUPAL_PRIVATE_FILES="${DRUPAL_PRIVATE_FILES:-${APP}/${WEBROOT}/sites/default/files/private}"

# Directory with database dump file.
DB_DIR="${DB_DIR:-./.data}"

# Database dump file name.
DB_FILE="${DB_FILE:-db.sql}"

# Flag to export database before import.
DB_EXPORT_BEFORE_IMPORT="${DB_EXPORT_BEFORE_IMPORT:-0}"

# Flag to skip DB import.
SKIP_DB_IMPORT="${SKIP_DB_IMPORT:-}"

# Flag to skip running post DB import commands.
SKIP_POST_DB_IMPORT="${SKIP_POST_DB_IMPORT:-}"

# ------------------------------------------------------------------------------

echo "==> Installing site."

# Create private files directory.
mkdir -p "${DRUPAL_PRIVATE_FILES}"

# Export database before importing, if the flag is set.
# Useful to automatically store database dump before starting site rebuild.
[ "${DB_EXPORT_BEFORE_IMPORT}" -eq 1 ] && ./scripts/drevops/drupal-export-db.sh

# Import database dump if present, or install fresh website from the profile if
# site is not already installed.
if [ -z "${SKIP_DB_IMPORT}" ] && [ -f "${DB_DIR}/${DB_FILE}" ]; then
  echo "==> Using existing DB dump ${DB_DIR}/${DB_FILE}."
  DB_DIR="${DB_DIR}" DB_FILE="${DB_FILE}" ./scripts/drevops/drupal-import-db.sh
elif drush ${DRUSH_ALIAS} status --fields=bootstrap | grep -q "Successful"; then
  echo "==> Existing site found."
else
  echo "==> Existing site not found. Installing site from profile ${DRUPAL_PROFILE}."
  drush ${DRUSH_ALIAS} si "${DRUPAL_PROFILE}" -y --account-name=admin --site-name="${DRUPAL_SITE_NAME}" install_configure_form.enable_update_status_module=NULL install_configure_form.enable_update_status_emails=NULL
fi

# Run post DB import scripts, if not skipped.
if [ -z "${SKIP_POST_DB_IMPORT}" ]; then
  echo "==> Running post DB init commands."
  # Enable custom site "core" module.
  # shellcheck disable=SC2015
  drush ${DRUSH_ALIAS} pml | grep -q "${DRUPAL_MODULE_PREFIX}_core" && drush ${DRUSH_ALIAS} en -y "${DRUPAL_MODULE_PREFIX}_core" || true

  # Run updates.
  drush ${DRUSH_ALIAS} updb -y
else
  echo "==> Skipped running of post DB init commands."
fi

# Rebuild cache.
drush ${DRUSH_ALIAS} cc all
