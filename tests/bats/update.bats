#!/usr/bin/env bats
#
# Test for update functionality.
#

load _helper
load _helper_drupaldev

@test "Update" {
  # Add custom files
  touch "test1.txt"
  # File resides in directory that is included in Drupal-Dev when initialised.
  mkdir -p ".docker"
  touch ".docker/test2.txt"

  git_init

  # Add all files to git repo.
  git_add_all_commit "First commit"
  assert_git_repo

  run_install
  assert_files_present
  assert_git_repo

  install_dependencies_stub

  git_add_all_commit "Init Drupal-Dev"

  # Assert that custom file preserved.
  assert_file_exists "test1.txt"
  # Assert that custom file in a directory used by Drupal-Dev is preserved.
  assert_file_exists ".docker/test2.txt"

  # Assert no changes were introduced.
  assert_git_clean

  # Releasing new version of Drupal-Dev (note that installing from the local tag
  # is not supported in install.sh; only commit is supported).
  echo "# Some change to docker-compose" >> "${LOCAL_REPO_DIR}/docker-compose.yml"
  git_add "docker-compose.yml" "${LOCAL_REPO_DIR}"
  echo "# Some change to non-required file" >> "${LOCAL_REPO_DIR}/.eslintrc.json"
  git_add "${LOCAL_REPO_DIR}" ".eslintrc.json"
  latest_commit=$(git_commit "New version of Drupal-Dev" "${LOCAL_REPO_DIR}")

  # Override Drupal-Dev release commit in .env file.
  echo DRUPALDEV_COMMIT="${latest_commit}">>.env
  # Override install script with currently tested one.
  export DRUPALDEV_INSTALL_SCRIPT="${CUR_DIR}/install.sh"
  # shellcheck disable=SC2059
  yes | ahoy update

  assert_files_present
  assert_git_repo

  install_dependencies_stub

  # Assert that committed files were updated.
  assert_file_contains "docker-compose.yml" "# Some change to docker-compose"
  assert_file_contains ".eslintrc.json" "# Some change to non-required file"

  # Assert that new changes need to be manually resolved.
  assert_git_not_clean
}
