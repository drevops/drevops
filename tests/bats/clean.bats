#!/usr/bin/env bats
#
# Test for clean functionality.
#

load test_helper
load test_helper_drupaldev

@test "Clean; non-exclude" {
  pushd "${CURRENT_PROJECT_DIR}" > /dev/null

  run_install

  assert_files_present "${CURRENT_PROJECT_DIR}"
  assert_git_repo "${CURRENT_PROJECT_DIR}"

  mktouch "docroot/core/install.php"
  mktouch "docroot/modules/contrib/somemodule/somemodule.info.yml"
  mktouch "docroot/themes/contrib/sometheme/sometheme.info.yml"
  mktouch "docroot/profiles/contrib/someprofile/someprofile.info.yml"
  mktouch "docroot/sites/default/somesettingsfile.php"
  mktouch "docroot/sites/default/settings.generated.php"
  mktouch "docroot/sites/default/files/somepublicfile.php"

  mktouch "vendor/somevendor/somepackage/somepackage.php"
  mktouch "vendor/somevendor/somepackage/somepackage with spaces.php"
  mktouch "vendor/somevendor/somepackage/composer.json"
  # Make sure that sub-repos removed.
  mktouch "vendor/othervendor/otherpackage/.git/HEAD"

  mktouch "node_modules/somevendor/somepackage/somepackage.js"
  mktouch "node_modules/somevendor/somepackage/somepackage with spaces.js"

  mktouch "docroot/themes/custom/somecustomtheme/build/js/somecustomtheme.min.js"
  mktouch "docroot/themes/custom/somecustomtheme/build/css/somecustomtheme.min.css"
  mktouch "docroot/themes/custom/somecustomtheme/scss/_components.scss"

  mktouch "screenshots/s1.jpg"
  mktouch "screenshots/s2.jpg"

  mktouch ".data/db.sql"
  mktouch ".data/db_2.sql"

  mktouch "docroot/sites/default/settings.local.php"
  mktouch "docroot/sites/default/services.local.yml"

  mktouch ".env.local"
  echo "version: \"2.3\"" > "docker-compose.override.yml"

  mktouch ".idea/some_ide_file"
  mktouch ".vscode/some_ide_file"
  mktouch "nbproject/some_ide_file"

  mktouch "uncommitted_file.txt"

  ahoy clean

  assert_files_present "${CURRENT_PROJECT_DIR}"
  assert_git_repo "${CURRENT_PROJECT_DIR}"

  assert_dir_not_exists "docroot/core"
  assert_dir_not_exists "docroot/modules/contrib"
  assert_dir_not_exists "docroot/themes/contrib"
  assert_dir_not_exists "docroot/profiles/contrib"

  assert_file_exists "docroot/sites/default/somesettingsfile.php"
  assert_file_not_exists "docroot/sites/default/settings.generated.php"
  assert_file_exists "docroot/sites/default/files/somepublicfile.php"

  assert_dir_not_exists "vendor"
  assert_dir_not_exists "node_modules"

  assert_dir_not_exists "docroot/themes/custom/somecustomtheme/build"
  assert_file_not_exists "docroot/themes/custom/somecustomtheme/scss/_components.scss"

  assert_file_exists "screenshots/s1.jpg"
  assert_file_exists "screenshots/s2.jpg"

  assert_file_exists ".data/db.sql"
  assert_file_exists ".data/db_2.sql"

  assert_file_exists "docroot/sites/default/settings.local.php"
  assert_file_exists "docroot/sites/default/services.local.yml"

  assert_file_exists ".env.local"
  assert_file_exists "docker-compose.override.yml"

  assert_file_exists ".idea/some_ide_file"
  assert_file_exists ".vscode/some_ide_file"
  assert_file_exists "nbproject/some_ide_file"

  assert_file_exists "uncommitted_file.txt"

  popd > /dev/null
}

@test "Clean; exclude" {
  export DRUPALDEV_ALLOW_USE_LOCAL_EXCLUDE=1
  pushd "${CURRENT_PROJECT_DIR}" > /dev/null

  run_install

  assert_files_present "${CURRENT_PROJECT_DIR}"
  assert_git_repo "${CURRENT_PROJECT_DIR}"

  mktouch "docroot/core/install.php"
  mktouch "docroot/modules/contrib/somemodule/somemodule.info.yml"
  mktouch "docroot/themes/contrib/sometheme/sometheme.info.yml"
  mktouch "docroot/profiles/contrib/someprofile/someprofile.info.yml"
  mktouch "docroot/sites/default/somesettingsfile.php"
  mktouch "docroot/sites/default/settings.generated.php"
  mktouch "docroot/sites/default/files/somepublicfile.php"

  mktouch "vendor/somevendor/somepackage/somepackage.php"
  mktouch "vendor/somevendor/somepackage/somepackage with spaces.php"
  mktouch "vendor/somevendor/somepackage/composer.json"
  # Make sure that sub-repos removed.
  mktouch "vendor/othervendor/otherpackage/.git/HEAD"

  mktouch "node_modules/somevendor/somepackage/somepackage.js"
  mktouch "node_modules/somevendor/somepackage/somepackage with spaces.js"

  mktouch "docroot/themes/custom/somecustomtheme/build/js/somecustomtheme.min.js"
  mktouch "docroot/themes/custom/somecustomtheme/build/css/somecustomtheme.min.css"
  mktouch "docroot/themes/custom/somecustomtheme/scss/_components.scss"

  mktouch "screenshots/s1.jpg"
  mktouch "screenshots/s2.jpg"

  mktouch ".data/db.sql"
  mktouch ".data/db_2.sql"

  mktouch "docroot/sites/default/settings.local.php"
  mktouch "docroot/sites/default/services.local.yml"

  mktouch ".env.local"
  echo "version: \"2.3\"" > "docker-compose.override.yml"

  mktouch ".idea/some_ide_file"
  mktouch ".vscode/some_ide_file"
  mktouch "nbproject/some_ide_file"

  mktouch "uncommitted_file.txt"

  ahoy clean

  assert_files_present "${CURRENT_PROJECT_DIR}"
  assert_git_repo "${CURRENT_PROJECT_DIR}"

  assert_dir_not_exists "docroot/core"
  assert_dir_not_exists "docroot/modules/contrib"
  assert_dir_not_exists "docroot/themes/contrib"
  assert_dir_not_exists "docroot/profiles/contrib"

  assert_file_exists "docroot/sites/default/somesettingsfile.php"
  assert_file_not_exists "docroot/sites/default/settings.generated.php"
  assert_file_exists "docroot/sites/default/files/somepublicfile.php"

  assert_dir_not_exists "vendor"
  assert_dir_not_exists "node_modules"

  assert_dir_not_exists "docroot/themes/custom/somecustomtheme/build"
  assert_file_not_exists "docroot/themes/custom/somecustomtheme/scss/_components.scss"

  assert_file_exists "screenshots/s1.jpg"
  assert_file_exists "screenshots/s2.jpg"

  assert_file_exists ".data/db.sql"
  assert_file_exists ".data/db_2.sql"

  assert_file_exists "docroot/sites/default/settings.local.php"
  assert_file_exists "docroot/sites/default/services.local.yml"

  assert_file_exists ".env.local"
  assert_file_exists "docker-compose.override.yml"

  assert_file_exists ".idea/some_ide_file"
  assert_file_exists ".vscode/some_ide_file"
  assert_file_exists "nbproject/some_ide_file"

  assert_file_exists "uncommitted_file.txt"

  popd > /dev/null
}

@test "Reset; non-exclude" {
  pushd "${CURRENT_PROJECT_DIR}" > /dev/null

  run_install

  assert_files_present "${CURRENT_PROJECT_DIR}"
  assert_git_repo "${CURRENT_PROJECT_DIR}"

  mktouch "docroot/core/install.php"
  mktouch "docroot/modules/contrib/somemodule/somemodule.info.yml"
  mktouch "docroot/themes/contrib/sometheme/sometheme.info.yml"
  mktouch "docroot/profiles/contrib/someprofile/someprofile.info.yml"
  mktouch "docroot/sites/default/somesettingsfile.php"
  mktouch "docroot/sites/default/settings.generated.php"
  mktouch "docroot/sites/default/files/somepublicfile.php"

  mktouch "vendor/somevendor/somepackage/somepackage.php"
  mktouch "vendor/somevendor/somepackage/somepackage with spaces.php"
  mktouch "vendor/somevendor/somepackage/composer.json"
  # Make sure that sub-repos removed.
  mktouch "vendor/othervendor/otherpackage/.git/HEAD"

  mktouch "node_modules/somevendor/somepackage/somepackage.js"
  mktouch "node_modules/somevendor/somepackage/somepackage with spaces.js"
  mktouch "docroot/themes/custom/somecustomtheme/scss/_components.scss"

  mktouch "docroot/themes/custom/somecustomtheme/build/js/somecustomtheme.min.js"
  mktouch "docroot/themes/custom/somecustomtheme/build/css/somecustomtheme.min.css"

  mktouch "screenshots/s1.jpg"
  mktouch "screenshots/s2.jpg"

  mktouch ".data/db.sql"
  mktouch ".data/db_2.sql"

  mktouch "docroot/sites/default/settings.local.php"
  mktouch "docroot/sites/default/services.local.yml"

  mktouch ".env.local"
  echo "version: \"2.3\"" > "docker-compose.override.yml"

  mktouch ".idea/some_ide_file"
  mktouch ".vscode/some_ide_file"
  mktouch "nbproject/some_ide_file"

  mktouch "uncommitted_file.txt"

  ahoy reset

  assert_files_present_common "${CURRENT_PROJECT_DIR}" "star_wars"
  assert_git_repo "${CURRENT_PROJECT_DIR}"

  assert_dir_not_exists "docroot/core"
  assert_dir_not_exists "docroot/modules/contrib"
  assert_dir_not_exists "docroot/themes/contrib"
  assert_dir_not_exists "docroot/profiles/contrib"

  assert_file_exists "docroot/sites/default/somesettingsfile.php"
  assert_file_not_exists "docroot/sites/default/settings.generated.php"
  assert_file_exists "docroot/sites/default/files/somepublicfile.php"

  assert_dir_not_exists "vendor"
  assert_dir_not_exists "node_modules"

  assert_dir_not_exists "docroot/themes/custom/somecustomtheme/build"
  assert_file_not_exists "docroot/themes/custom/somecustomtheme/scss/_components.scss"

  assert_dir_not_exists "screenshots"

  assert_file_exists ".data/db.sql"
  assert_file_exists ".data/db_2.sql"

  assert_file_exists "docroot/sites/default/settings.local.php"
  assert_file_exists "docroot/sites/default/services.local.yml"

  assert_file_exists ".env.local"
  assert_file_exists "docker-compose.override.yml"

  assert_file_exists ".idea/some_ide_file"
  assert_file_exists ".vscode/some_ide_file"
  assert_file_exists "nbproject/some_ide_file"

  assert_file_exists "uncommitted_file.txt"

  popd > /dev/null
}

@test "Reset; exclude" {
  export DRUPALDEV_ALLOW_USE_LOCAL_EXCLUDE=1

  pushd "${CURRENT_PROJECT_DIR}" > /dev/null

  run_install

  assert_files_present "${CURRENT_PROJECT_DIR}"
  assert_git_repo "${CURRENT_PROJECT_DIR}"

  mktouch "docroot/core/install.php"
  mktouch "docroot/modules/contrib/somemodule/somemodule.info.yml"
  mktouch "docroot/themes/contrib/sometheme/sometheme.info.yml"
  mktouch "docroot/profiles/contrib/someprofile/someprofile.info.yml"
  mktouch "docroot/sites/default/somesettingsfile.php"
  mktouch "docroot/sites/default/settings.generated.php"
  mktouch "docroot/sites/default/files/somepublicfile.php"

  mktouch "vendor/somevendor/somepackage/somepackage.php"
  mktouch "vendor/somevendor/somepackage/somepackage with spaces.php"
  mktouch "vendor/somevendor/somepackage/composer.json"
  # Make sure that sub-repos removed.
  mktouch "vendor/othervendor/otherpackage/.git/HEAD"

  mktouch "node_modules/somevendor/somepackage/somepackage.js"
  mktouch "node_modules/somevendor/somepackage/somepackage with spaces.js"
  mktouch "docroot/themes/custom/somecustomtheme/scss/_components.scss"

  mktouch "docroot/themes/custom/somecustomtheme/build/js/somecustomtheme.min.js"
  mktouch "docroot/themes/custom/somecustomtheme/build/css/somecustomtheme.min.css"

  mktouch "screenshots/s1.jpg"
  mktouch "screenshots/s2.jpg"

  mktouch ".data/db.sql"
  mktouch ".data/db_2.sql"

  mktouch "docroot/sites/default/settings.local.php"
  mktouch "docroot/sites/default/services.local.yml"

  mktouch ".env.local"
  echo "version: \"2.3\"" > "docker-compose.override.yml"

  mktouch ".idea/some_ide_file"
  mktouch ".vscode/some_ide_file"
  mktouch "nbproject/some_ide_file"

  mktouch "uncommitted_file.txt"

  ahoy reset

  assert_files_not_present_common "${CURRENT_PROJECT_DIR}" "star_wars" 1
  assert_git_repo "${CURRENT_PROJECT_DIR}"

  assert_dir_not_exists "docroot/core"
  assert_dir_not_exists "docroot/modules/contrib"
  assert_dir_not_exists "docroot/themes/contrib"
  assert_dir_not_exists "docroot/profiles/contrib"

  assert_file_exists "docroot/sites/default/somesettingsfile.php"
  assert_file_not_exists "docroot/sites/default/settings.generated.php"
  assert_file_exists "docroot/sites/default/files/somepublicfile.php"

  assert_dir_not_exists "vendor"
  assert_dir_not_exists "node_modules"

  assert_dir_not_exists "docroot/themes/custom/somecustomtheme/build"
  assert_file_not_exists "docroot/themes/custom/somecustomtheme/scss/_components.scss"

  assert_dir_not_exists "screenshots"

  assert_file_exists ".data/db.sql"
  assert_file_exists ".data/db_2.sql"

  assert_file_exists "docroot/sites/default/settings.local.php"
  assert_file_exists "docroot/sites/default/services.local.yml"

  assert_file_exists ".env.local"
  assert_file_exists "docker-compose.override.yml"

  assert_file_exists ".idea/some_ide_file"
  assert_file_exists ".vscode/some_ide_file"
  assert_file_exists "nbproject/some_ide_file"

  assert_file_exists "uncommitted_file.txt"

  popd > /dev/null
}

@test "Reset; committed files; non-exclude" {
  pushd "${CURRENT_PROJECT_DIR}" > /dev/null

  run_install

  assert_files_present "${CURRENT_PROJECT_DIR}"
  assert_git_repo "${CURRENT_PROJECT_DIR}"

  mktouch "docroot/core/install.php"
  mktouch "docroot/modules/contrib/somemodule/somemodule.info.yml"
  mktouch "docroot/themes/contrib/sometheme/sometheme.info.yml"
  mktouch "docroot/profiles/contrib/someprofile/someprofile.info.yml"
  mktouch "docroot/sites/default/somesettingsfile.php"
  mktouch "docroot/sites/default/settings.generated.php"
  mktouch "docroot/sites/default/files/somepublicfile.php"

  mktouch "vendor/somevendor/somepackage/somepackage.php"
  mktouch "vendor/somevendor/somepackage/somepackage with spaces.php"
  mktouch "vendor/somevendor/somepackage/composer.json"
  # Make sure that sub-repos removed.
  mktouch "vendor/othervendor/otherpackage/.git/HEAD"

  mktouch "node_modules/somevendor/somepackage/somepackage.js"
  mktouch "node_modules/somevendor/somepackage/somepackage with spaces.js"

  mktouch "docroot/themes/custom/somecustomtheme/build/js/somecustomtheme.min.js"
  mktouch "docroot/themes/custom/somecustomtheme/build/css/somecustomtheme.min.css"
  mktouch "docroot/themes/custom/somecustomtheme/scss/_components.scss"

  mktouch "screenshots/s1.jpg"
  mktouch "screenshots/s2.jpg"

  mktouch ".data/db.sql"
  mktouch ".data/db_2.sql"

  mktouch "docroot/sites/default/settings.local.php"
  mktouch "docroot/sites/default/services.local.yml"

  mktouch ".env.local"
  echo "version: \"2.3\"" > "docker-compose.override.yml"

  mktouch ".idea/some_ide_file"
  mktouch ".vscode/some_ide_file"
  mktouch "nbproject/some_ide_file"

  mktouch "uncommitted_file.txt"

  git_add_all_commit "${CURRENT_PROJECT_DIR}" "Added Drupal-Dev files"

  # Commit other file file.
  mktouch "committed_file.txt"
  git add "committed_file.txt"
  git commit -m "Added custom file" > /dev/null

  ahoy reset

  assert_files_present_common "${CURRENT_PROJECT_DIR}" "star_wars"
  assert_git_repo "${CURRENT_PROJECT_DIR}"

  assert_dir_not_exists "docroot/core"
  assert_dir_not_exists "docroot/modules/contrib"
  assert_dir_not_exists "docroot/themes/contrib"
  assert_dir_not_exists "docroot/profiles/contrib"

  assert_file_exists "docroot/sites/default/somesettingsfile.php"
  assert_file_not_exists "docroot/sites/default/settings.generated.php"
  assert_file_exists "docroot/sites/default/files/somepublicfile.php"

  assert_dir_not_exists "vendor"
  assert_dir_not_exists "node_modules"

  assert_dir_not_exists "docroot/themes/custom/somecustomtheme/build"
  assert_file_not_exists "docroot/themes/custom/somecustomtheme/scss/_components.scss"

  assert_dir_not_exists "screenshots"

  assert_file_exists ".data/db.sql"
  assert_file_exists ".data/db_2.sql"

  assert_file_exists "docroot/sites/default/settings.local.php"
  assert_file_exists "docroot/sites/default/services.local.yml"

  assert_file_exists ".env.local"
  assert_file_exists "docker-compose.override.yml"

  assert_file_exists ".idea/some_ide_file"
  assert_file_exists ".vscode/some_ide_file"
  assert_file_exists "nbproject/some_ide_file"

  assert_file_exists "uncommitted_file.txt"

  assert_file_exists "scripts/download-backup-acquia.sh"
  assert_file_exists "committed_file.txt"

  popd > /dev/null
}

@test "Reset; committed files; exclude" {
  export DRUPALDEV_ALLOW_USE_LOCAL_EXCLUDE=1

  pushd "${CURRENT_PROJECT_DIR}" > /dev/null

  run_install

  assert_files_present "${CURRENT_PROJECT_DIR}"
  assert_git_repo "${CURRENT_PROJECT_DIR}"

  mktouch "docroot/core/install.php"
  mktouch "docroot/modules/contrib/somemodule/somemodule.info.yml"
  mktouch "docroot/themes/contrib/sometheme/sometheme.info.yml"
  mktouch "docroot/profiles/contrib/someprofile/someprofile.info.yml"
  mktouch "docroot/sites/default/somesettingsfile.php"
  mktouch "docroot/sites/default/settings.generated.php"
  mktouch "docroot/sites/default/files/somepublicfile.php"

  mktouch "vendor/somevendor/somepackage/somepackage.php"
  mktouch "vendor/somevendor/somepackage/somepackage with spaces.php"
  mktouch "vendor/somevendor/somepackage/composer.json"
  # Make sure that sub-repos removed.
  mktouch "vendor/othervendor/otherpackage/.git/HEAD"

  mktouch "node_modules/somevendor/somepackage/somepackage.js"
  mktouch "node_modules/somevendor/somepackage/somepackage with spaces.js"

  mktouch "docroot/themes/custom/somecustomtheme/build/js/somecustomtheme.min.js"
  mktouch "docroot/themes/custom/somecustomtheme/build/css/somecustomtheme.min.css"
  mktouch "docroot/themes/custom/somecustomtheme/scss/_components.scss"

  mktouch "screenshots/s1.jpg"
  mktouch "screenshots/s2.jpg"

  mktouch ".data/db.sql"
  mktouch ".data/db_2.sql"

  mktouch "docroot/sites/default/settings.local.php"
  mktouch "docroot/sites/default/services.local.yml"

  mktouch ".env.local"
  echo "version: \"2.3\"" > "docker-compose.override.yml"

  mktouch ".idea/some_ide_file"
  mktouch ".vscode/some_ide_file"
  mktouch "nbproject/some_ide_file"

  mktouch "uncommitted_file.txt"

  # Commit Drupal-Dev's file (have to force-add).
  git add -f "scripts/download-backup-acquia.sh"
  git commit -m "Added Acquia backup script" > /dev/null

  # Commit other file file.
  mktouch "committed_file.txt"
  git add "committed_file.txt"
  git commit -m "Added custom file" > /dev/null

  ahoy reset

  assert_files_not_present_common "${CURRENT_PROJECT_DIR}" "star_wars" 1
  assert_git_repo "${CURRENT_PROJECT_DIR}"

  assert_dir_not_exists "docroot/core"
  assert_dir_not_exists "docroot/modules/contrib"
  assert_dir_not_exists "docroot/themes/contrib"
  assert_dir_not_exists "docroot/profiles/contrib"

  assert_file_exists "docroot/sites/default/somesettingsfile.php"
  assert_file_not_exists "docroot/sites/default/settings.generated.php"
  assert_file_exists "docroot/sites/default/files/somepublicfile.php"

  assert_dir_not_exists "vendor"
  assert_dir_not_exists "node_modules"

  assert_dir_not_exists "docroot/themes/custom/somecustomtheme/build"
  assert_file_not_exists "docroot/themes/custom/somecustomtheme/scss/_components.scss"

  assert_dir_not_exists "screenshots"

  assert_file_exists ".data/db.sql"
  assert_file_exists ".data/db_2.sql"

  assert_file_exists "docroot/sites/default/settings.local.php"
  assert_file_exists "docroot/sites/default/services.local.yml"

  assert_file_exists ".env.local"
  assert_file_exists "docker-compose.override.yml"

  assert_file_exists ".idea/some_ide_file"
  assert_file_exists ".vscode/some_ide_file"
  assert_file_exists "nbproject/some_ide_file"

  assert_file_exists "uncommitted_file.txt"

  assert_file_exists "scripts/download-backup-acquia.sh"
  assert_file_exists "committed_file.txt"

  popd > /dev/null
}
