#!/usr/bin/env bats
#
# Init tests.
#

load test_helper
load test_helper_init

@test "Init all" {
  copy_code

  init_project 'Star Wars\n\n\n\n\n\n\n\n'

  assert_files_init_common

  # Acquia integration preserved.
  assert_dir_exists hooks
  assert_dir_exists hooks/library
  assert_file_mode hooks/library/clear-cache.sh "755"
  assert_file_mode hooks/library/enable-shield.sh "755"
  assert_file_mode hooks/library/flush-varnish.sh "755"
  assert_file_mode hooks/library/import-config.sh "755"
  assert_file_mode hooks/library/update-db.sh "755"
  assert_file_exists scripts/download-backup-acquia.sh
  assert_file_exists DEPLOYMENT.md
  assert_file_contains README.md "Please refer to [DEPLOYMENT.md](DEPLOYMENT.md)"
  assert_file_contains docroot/sites/default/settings.php "if (file_exists('/var/www/site-php')) {"
  assert_file_contains .env "AC_API_DB_SITE="
  assert_file_contains .env "AC_API_DB_ENV="
  assert_file_contains .env "AC_API_DB_NAME="
  assert_file_contains .ahoy.yml "AC_API_DB_SITE="
  assert_file_contains .ahoy.yml "AC_API_DB_ENV="
  assert_file_contains .ahoy.yml "AC_API_DB_NAME="

  # Lagoon integration preserved.
  assert_file_exists .lagoon.yml
  assert_file_exists drush/aliases.drushrc.php
  assert_file_contains docker-compose.yml "labels"
  assert_file_contains docker-compose.yml "lagoon.type: cli-persistent"
  assert_file_contains docker-compose.yml "lagoon.persistent.name: nginx"
  assert_file_contains docker-compose.yml "lagoon.persistent: /app/docroot/sites/default/files/"
  assert_file_contains docker-compose.yml "lagoon.type: nginx-php-persistent"
  assert_file_contains docker-compose.yml "lagoon.name: nginx"
  assert_file_contains docker-compose.yml "lagoon.type: mariadb"
  assert_file_contains docker-compose.yml "lagoon.type: solr"
  assert_file_contains docker-compose.yml "lagoon.type: none"

  # Assert that project name is correct.
  assert_file_contains .env "PROJECT=\"star_wars\""
}

@test "Init none" {
  copy_code

  init_project 'Star Wars\n\n\n\n\nno\nno\n\n'

  assert_files_init_common

  # Acquia integration removed.
  assert_dir_not_exists hooks
  assert_file_not_exists scripts/download-backup-acquia.sh
  assert_file_not_exists DEPLOYMENT.md
  assert_file_not_contains README.md "Please refer to [DEPLOYMENT.md](DEPLOYMENT.md)"
  assert_file_not_contains docroot/sites/default/settings.php "if (file_exists('/var/www/site-php')) {"
  assert_file_not_contains .env "AC_API_DB_SITE="
  assert_file_not_contains .env "AC_API_DB_ENV="
  assert_file_not_contains .env "AC_API_DB_NAME="
  assert_file_not_contains .ahoy.yml "AC_API_DB_SITE="
  assert_file_not_contains .ahoy.yml "AC_API_DB_ENV="
  assert_file_not_contains .ahoy.yml "AC_API_DB_NAME="

  # Lagoon integration removed.
  assert_file_not_exists .lagoon.yml
  assert_file_not_exists drush/aliases.drushrc.php
  assert_file_not_contains docker-compose.yml "labels"
  assert_file_not_contains docker-compose.yml "lagoon."

  # Assert that project name is correct.
  assert_file_contains .env "PROJECT=\"star_wars\""
}
