#!/usr/bin/env bats
#
# Test installation into empty directory.
#

load _helper
load _helper_drupaldev

@test "Variables" {
  assert_contains "drupal-dev" "${BUILD_DIR}"
}

@test "Install into empty directory" {
  run_install

  assert_files_present
  assert_git_repo
}

@test "Install into empty directory: DST_DIR as argument" {
  run_install "${DST_PROJECT_DIR}"

  assert_files_present "dst" "Dst" "${DST_PROJECT_DIR}"
  assert_git_repo "${DST_PROJECT_DIR}"
}

@test "Install into empty directory: DST_DIR from env variable" {
  export DST_DIR="${DST_PROJECT_DIR}"
  run_install

  assert_files_present "dst" "Dst" "${DST_PROJECT_DIR}"
  assert_git_repo "${DST_PROJECT_DIR}"
}

@test "Install into empty directory: PROJECT from env variable" {
  export PROJECT="the_matrix"
  run_install

  assert_files_present "the_matrix" "TheMatrix"
  assert_git_repo
}

@test "Install into empty directory: PROJECT from .env file" {
  echo "PROJECT=\"the_matrix\"" > ".env"

  run_install

  assert_files_present "the_matrix" "TheMatrix"
  assert_git_repo
}

@test "Install into empty directory: install from specific commit" {
  run_install
  assert_files_present
  assert_git_repo

  # Releasing 2 new versions of Drupal-Dev.
  echo "# Some change to docker-compose at commit 1" >> "${LOCAL_REPO_DIR}/docker-compose.yml"
  git_add "docker-compose.yml" "${LOCAL_REPO_DIR}"
  commit1=$(git_commit "New version 1 of Drupal-Dev" "${LOCAL_REPO_DIR}")

  echo "# Some change to docker-compose at commit 2" >> "${LOCAL_REPO_DIR}/docker-compose.yml"
  git_add "docker-compose.yml" "${LOCAL_REPO_DIR}"
  commit2=$(git_commit "New version 2 of Drupal-Dev" "${LOCAL_REPO_DIR}")

  # Requiring bespoke version by commit.
  echo DRUPALDEV_COMMIT="${commit1}">>.env
  run_install
  assert_git_repo
  assert_output_contains "This will install Drupal-Dev into your project at commit"
  assert_output_contains "Downloading Drupal-Dev at ref ${commit1}"

  assert_files_present
  assert_file_contains "docker-compose.yml" "# Some change to docker-compose at commit 1"
  assert_file_not_contains "docker-compose.yml" "# Some change to docker-compose at commit 2"
}

@test "Install into empty directory: empty directory; no local ignore" {
   run_install
  assert_files_present
  assert_git_repo

  assert_file_not_contains ".git/info/exclude" ".ahoy.yml"
}

@test "Install into empty directory: interactive" {
  answers=(
    "Star wars" # name
    "nothing" # machine_name
    "nothing" # org
    "nothing" # morh_machine_name
    "nothing" # module_prefix
    "nothing" # profile
    "nothing" # theme
    "nothing" # URL
    "nothing" # fresh_install
    "nothing" # preserve_deployment
    "nothing" # preserve_acquia
    "nothing" # preserve_lagoon
    "nothing" # preserve_ftp
    "nothing" # preserve_dependenciesio
    "nothing" # preserve_doc_comments
    "nothing" # remove_drupaldev_info
  )
  output=$(run_install_interactive "${answers[@]}")
  assert_output_contains "WELCOME TO DRUPAL-DEV INTERACTIVE INSTALLER"

  assert_files_present
  assert_git_repo
}

@test "Install into empty directory: interactive; override; should override changed committed file and have no changes" {
  echo "SOMEVAR=\"someval\"" >> .env

  answers=(
    "Star wars" # name
    "nothing" # machine_name
    "nothing" # org
    "nothing" # morh_machine_name
    "nothing" # module_prefix
    "nothing" # profile
    "nothing" # theme
    "nothing" # URL
    "nothing" # fresh_install
    "nothing" # preserve_deployment
    "nothing" # preserve_acquia
    "nothing" # preserve_lagoon
    "nothing" # preserve_ftp
    "nothing" # preserve_dependenciesio
    "nothing" # preserve_doc_comments
    "nothing" # remove_drupaldev_info
  )
  output=$(run_install_interactive "${answers[@]}")
  assert_output_contains "WELCOME TO DRUPAL-DEV INTERACTIVE INSTALLER"

  assert_files_present
  assert_git_repo

  assert_file_not_contains ".env" "SOMEVAR="
}

@test "Install into empty directory: silent; should NOT show that Drupal-Dev was previously installed" {
  output=$(run_install)
  assert_output_contains "WELCOME TO DRUPAL-DEV SILENT INSTALLER"
  assert_output_not_contains "It looks like Drupal-Dev is already installed into this project"

  assert_files_present
  assert_git_repo
}

@test "Install into empty directory: interactive; should show that Drupal-Dev was previously installed" {
  answers=(
    "Star wars" # name
    "nothing" # machine_name
    "nothing" # org
    "nothing" # morh_machine_name
    "nothing" # module_prefix
    "nothing" # profile
    "nothing" # theme
    "nothing" # URL
    "nothing" # fresh_install
    "nothing" # preserve_deployment
    "nothing" # preserve_acquia
    "nothing" # preserve_lagoon
    "nothing" # preserve_ftp
    "nothing" # preserve_dependenciesio
    "nothing" # preserve_doc_comments
    "nothing" # remove_drupaldev_info
  )
  output=$(run_install_interactive "${answers[@]}")
  assert_output_contains "WELCOME TO DRUPAL-DEV INTERACTIVE INSTALLER"
  assert_output_not_contains "It looks like Drupal-Dev is already installed into this project"

  assert_files_present
  assert_git_repo
}

@test "Install into empty directory; Drupal-Dev badge version set" {
  export DRUPALDEV_VERSION="7.x-1.2.3"

  run_install

  # Assert that Drupal-Dev version was replaced.
  assert_file_contains "README.md" "https://github.com/integratedexperts/drupal-dev/tree/7.x-1.2.3"
  assert_file_contains "README.md" "badge/Drupal--Dev-7.x--1.2.3-blue.svg"
}
