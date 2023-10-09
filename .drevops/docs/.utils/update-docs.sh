#!/usr/bin/env bash
##
# Update docs.
#
# @usage
# cd .drevops/docs && ./update-docs.sh
#
# shellcheck disable=SC2129

set -eu
[ "${DREVOPS_DEBUG-}" = "1" ] && set -x

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"

[ ! -d "./.utils/vendor" ] && composer --working-dir="./.utils" install

sed_opts=(-i) && [ "$(uname)" = "Darwin" ] && sed_opts=(-i '')

OUTPUT_FILE="./content/workflows/variables.md"
sed "${sed_opts[@]}" '/## Variables list/,$d' "${OUTPUT_FILE}"

echo "## Variables list" >>"${OUTPUT_FILE}"
echo >>"${OUTPUT_FILE}"
./.utils/vendor/bin/shell-variables-extractor \
  --skip-text="@docs:skip" \
  --skip-description-prefix=";<" \
  --skip-description-prefix=";>" \
  --exclude-local \
  --exclude-from-file=./.utils/variables/variables.excluded.txt \
  --sort \
  --unset "UNDEFINED" \
  --format=md-blocks \
  --md-inline-code-extra-file=./.utils/variables/variables.inline-code-extra.txt \
  --md-link-vars \
  --md-link-vars-anchor-case=upper \
  --md-block-template-file=./.utils/variables/variables.template.md \
  --path-strip-prefix="${ROOT_DIR}/" \
  ../../.env \
  ../../.env.local.default \
  ./.utils/variables/extra \
  .. \
  >>"${OUTPUT_FILE}"

sed "${sed_opts[@]}" "s/.drevops\/docs\/.utils\/variables\/extra\/environment.variables.sh/ENVIRONMENT/g" "${OUTPUT_FILE}"
sed "${sed_opts[@]}" "s/.drevops\/docs\/.utils\/variables\/extra\/acquia.variables.sh/ACQUIA ENVIRONMENT/g" "${OUTPUT_FILE}"
sed "${sed_opts[@]}" "s/.drevops\/docs\/.utils\/variables\/extra\/lagoon.variables.sh/LAGOON ENVIRONMENT/g" "${OUTPUT_FILE}"
sed "${sed_opts[@]}" "s/.drevops\/docs\/.utils\/variables\/extra\/.env.local.default.variables.sh/.env.local.default/g" "${OUTPUT_FILE}"
sed "${sed_opts[@]}" "s/.drevops\/docs\/.utils\/variables\/extra\/.env.variables.sh/.env/g" "${OUTPUT_FILE}"
sed "${sed_opts[@]}" "s/.drevops\/docs\/.utils\/variables\/extra\/ci.variables.sh/CI config/g" "${OUTPUT_FILE}"
