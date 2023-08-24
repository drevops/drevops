#!/usr/bin/env bash
##
# Notification dispatch to email recipients.
#
# Notification dispatch to email recipients.
#
# Usage:
# DREVOPS_NOTIFY_PROJECT="Site Name" \
# DREVOPS_DRUPAL_SITE_EMAIL="from@example.com" \
# DREVOPS_NOTIFY_EMAIL_RECIPIENTS="to1@example.com|Jane Doe, to2@example.com|John Doe" \
# DREVOPS_NOTIFY_REF="git-branch" \
# DREVOPS_NOTIFY_ENVIRONMENT_URL="https://environment-url-example.com" \
# ./notify-email.sh
#

t=$(mktemp) && export -p >"$t" && set -a && . ./.env && if [ -f ./.env.local ]; then . ./.env.local; fi && set +a && . "$t" && rm "$t" && unset t

set -eu
[ "${DREVOPS_DEBUG-}" = "1" ] && set -x

# Project name to notify.
DREVOPS_NOTIFY_EMAIL_PROJECT="${DREVOPS_NOTIFY_EMAIL_PROJECT:-${DREVOPS_NOTIFY_PROJECT:-$1}}"

# Email address to send notifications from.
DREVOPS_NOTIFY_EMAIL_FROM="${DREVOPS_NOTIFY_EMAIL_FROM:-${DREVOPS_DRUPAL_SITE_EMAIL:-$2}}"

# Email address(es) to send notifications to.
#
# Multiple names can be specified as a comma-separated list of email addresses
# with optional names in the format "email|name".
# Example: "to1@example.com|Jane Doe, to2@example.com|John Doe"
DREVOPS_NOTIFY_EMAIL_RECIPIENTS="${DREVOPS_NOTIFY_EMAIL_RECIPIENTS:-$3}"

# Git reference to notify about.
DREVOPS_NOTIFY_EMAIL_REF="${DREVOPS_NOTIFY_EMAIL_REF:-${DREVOPS_NOTIFY_REF:-$4}}"

# Environment URL to notify about.
DREVOPS_NOTIFY_EMAIL_ENVIRONMENT_URL="${DREVOPS_NOTIFY_EMAIL_ENVIRONMENT_URL:-${DREVOPS_NOTIFY_ENVIRONMENT_URL:-$5}}"

#-------------------------------------------------------------------------------

# @formatter:off
note() { printf "       %s\n" "$1"; }
info() { [ -z "${TERM_NO_COLOR:-}" ] && tput colors >/dev/null 2>&1 && printf "\033[34m[INFO] %s\033[0m\n" "$1" || printf "[INFO] %s\n" "$1"; }
pass() { [ -z "${TERM_NO_COLOR:-}" ] && tput colors >/dev/null 2>&1 && printf "\033[32m[ OK ] %s\033[0m\n" "$1" || printf "[ OK ] %s\n" "$1"; }
fail() { [ -z "${TERM_NO_COLOR:-}" ] && tput colors >/dev/null 2>&1 && printf "\033[31m[FAIL] %s\033[0m\n" "$1" || printf "[FAIL] %s\n" "$1"; }
# @formatter:on

[ -z "$DREVOPS_NOTIFY_EMAIL_PROJECT" ] && fail "Both environment variable DREVOPS_NOTIFY_EMAIL_PROJECT and the first argument are empty." && exit 1
[ -z "$DREVOPS_NOTIFY_EMAIL_FROM" ] && fail "Both environment variable DREVOPS_NOTIFY_EMAIL_FROM and the second argument are empty." && exit 1
[ -z "$DREVOPS_NOTIFY_EMAIL_RECIPIENTS" ] && fail "Both environment variable DREVOPS_NOTIFY_EMAIL_RECIPIENTS and the third argument are empty." && exit 1
[ -z "$DREVOPS_NOTIFY_EMAIL_REF" ] && fail "Both environment variable DREVOPS_NOTIFY_EMAIL_REF and the fourth argument are empty." && exit 1
[ -z "$DREVOPS_NOTIFY_EMAIL_ENVIRONMENT_URL" ] && fail "Both environment variable DREVOPS_NOTIFY_EMAIL_ENVIRONMENT_URL and the fifth argument are empty." && exit 1

info "Started email notification."

has_mail=0
has_sendmail=0
if command -v mail >/dev/null 2>&1; then
  note "Using mail command to send emails."
  has_mail=1
elif command -v sendmail >/dev/null 2>&1; then
  note "Using sendmail command to send emails."
  has_sendmail=1
else
  fail "Neither mail nor sendmail commands are available."
  exit 1
fi

timestamp=$(date '+%d/%m/%Y %H:%M:%S %Z')
subject="${DREVOPS_NOTIFY_EMAIL_PROJECT} deployment notification of \"${DREVOPS_NOTIFY_EMAIL_REF}\""
content="## This is an automated message ##

Site ${DREVOPS_NOTIFY_EMAIL_PROJECT} \"${DREVOPS_NOTIFY_EMAIL_REF}\" branch has been deployed at ${timestamp} and is available at ${DREVOPS_NOTIFY_EMAIL_ENVIRONMENT_URL}.

Login at: ${DREVOPS_NOTIFY_EMAIL_ENVIRONMENT_URL}/user/login"

sent=""
IFS=","
# shellcheck disable=SC2086
set -- $DREVOPS_NOTIFY_EMAIL_RECIPIENTS
for email_with_name; do
  old_ifs="$IFS"
  IFS="|"
  # shellcheck disable=SC2086
  set -- $email_with_name
  email="${1#"${1%%[![:space:]]*}"}"
  email="${email%"${email##*[![:space:]]}"}"
  name="${2#"${2%%[![:space:]]*}"}"
  name="${name%"${name##*[![:space:]]}"}"
  IFS="$old_ifs"

  to="${name:+\"${name}\" }<${email}>"

  if [ "${has_mail}" = "1" ]; then
    mail -s "$subject" "$to" <<-EOF
    From: ${DREVOPS_NOTIFY_EMAIL_FROM}

    ${content}
EOF
    sent="${sent} ${email}"
  elif [ "${has_sendmail}" = "1" ]; then
    (
      echo "To: $to"
      echo "Subject: $subject"
      echo "From: ${DREVOPS_NOTIFY_EMAIL_FROM}"
      echo
      echo "${content}"
    ) | sendmail -t
    sent="${sent} ${email}"
  fi
done

sent="${sent#"${sent%%[![:space:]]*}"}"
sent="${sent%"${sent##*[![:space:]]}"}"

if [ -n "${sent}" ]; then
  note "Notification email(s) sent to: ${sent// /, }"
else
  note "No notification emails were sent."
fi

pass "Finished email notification."