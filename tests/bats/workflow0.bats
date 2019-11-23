#!/usr/bin/env bats
#
# DB-driven workflow.
#
# Due to test speed efficiency, all assertions ran withing a single test.

load _helper
load _helper_drevops
load _helper_drevops_workflow

@test "Workflow: DB-driven" {
  prepare_sut "Starting DB-driven WORKFLOW tests for Drupal ${DRUPAL_VERSION} in build directory ${BUILD_DIR}"

  # Point demo database to the test database.
  enable_demo_db

  assert_ahoy_download_db

  assert_ahoy_build
  assert_gitignore

  assert_ahoy_cli

  assert_env_changes

  assert_ahoy_drush

  assert_ahoy_info

  assert_ahoy_docker_logs

  assert_ahoy_login

  assert_ahoy_export_db

  assert_ahoy_lint

  assert_ahoy_test_unit

  assert_ahoy_test_bdd

  assert_ahoy_fe

  assert_export_on_install_site

  assert_ahoy_debug

  assert_ahoy_clean

  assert_ahoy_reset
}

@test "Idempotence" {
  prepare_sut "Starting idempotence tests for Drupal ${DRUPAL_VERSION} in build directory ${BUILD_DIR}"

  # Download DEMO database.
  enable_demo_db
  assert_ahoy_download_db

  assert_ahoy_build
  assert_gitignore
  assert_ahoy_test_bdd

  # Running build several times should result in the same project build results.
  assert_ahoy_build
  # Skip committing of the files.
  assert_gitignore 1
  assert_ahoy_test_bdd
}
