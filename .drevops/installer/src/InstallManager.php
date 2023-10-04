<?php

namespace DrevOps\Installer;

use DrevOps\Installer\Bag\Config;
use DrevOps\Installer\Utils\Env;
use DrevOps\Installer\Utils\Executor;
use DrevOps\Installer\Utils\Files;
use DrevOps\Installer\Utils\Output;
use DrevOps\Installer\Utils\Tokenizer;
use RuntimeException;

class InstallManager {

  /**
   * Defines Drupal version supported by this installer.
   */
  public const INSTALLER_DRUPAL_VERSION = 9;

  protected $downloadManager;

  protected $config;

  /**
   * Check that DrevOps is installed for this project.
   *
   * @param string $dst_dir
   *
   * @return bool
   * @todo Move this elsewhere.
   *
   */
  public static function isInstalled(string $dst_dir) {
    $path = $dst_dir . DIRECTORY_SEPARATOR . 'README.md';

    return file_exists($path) && preg_match('/badge\/DrevOps\-/', file_get_contents($path));
  }

  public function install($config) {
    return;
    $this->config = $config;

    $this->checkRequirements();

    $this->downloadManager->download();

    $this->prepareDestination();

    Tokenizer::replaceTokens();

    $this->copyFiles();

    ProcessorManager::processDemo();
  }

  public function checkRequirements() {
    Executor::commandExists('git');
    Executor::commandExists('tar');
    Executor::commandExists('composer');
  }

  public function prepareDestination() {
    $dst = Config::getDstDir();

    if (!is_dir($dst)) {
      Output::status(sprintf('Creating destination directory "%s".', $dst), Output::INSTALLER_STATUS_MESSAGE, FALSE);
      mkdir($dst);
      if (!is_writable($dst)) {
        throw new RuntimeException(sprintf('Destination directory "%s" is not writable.', $dst));
      }
      print ' ';
      Output::status('Done', Output::INSTALLER_STATUS_SUCCESS);
    }

    if (is_readable("$dst/.git")) {
      Output::status(sprintf('Git repository exists in "%s" - skipping initialisation.', $dst), Output::INSTALLER_STATUS_MESSAGE, FALSE);
    }
    else {
      Output::status(sprintf('Initialising Git repository in directory "%s".', $dst), Output::INSTALLER_STATUS_MESSAGE, FALSE);
      Executor::doExec("git --work-tree=\"$dst\" --git-dir=\"$dst/.git\" init > /dev/null");
      if (!is_readable("$dst/.git")) {
        throw new RuntimeException(sprintf('Unable to init git project in directory "%s".', $dst));
      }
    }
    print ' ';
    Output::status('Done', Output::INSTALLER_STATUS_SUCCESS);
  }

  public function copyFiles() {
    $src = Config::get(Env::INSTALLER_TMP_DIR);
    $dst = Config::getDstDir();

    // Due to the way symlinks can be ordered, we cannot copy files one-by-one
    // into destination directory. Instead, we are removing all ignored files
    // and empty directories, making the src directory "clean", and then
    // recursively copying the whole directory.
    $all = Files::scandirRecursive($src, Files::ignorePaths(), TRUE);
    $files = Files::scandirRecursive($src);
    $valid_files = Files::scandirRecursive($src, Files::ignorePaths());
    $dirs = array_diff($all, $valid_files);
    $ignored_files = array_diff($files, $valid_files);

    Output::status('Copying files', Output::INSTALLER_STATUS_DEBUG);

    foreach ($valid_files as $filename) {
      $relative_file = str_replace($src . DIRECTORY_SEPARATOR, '.' . DIRECTORY_SEPARATOR, $filename);

      if (Files::isInternalPath($relative_file)) {
        Output::status("Skipped file $relative_file as an internal DrevOps file.", Output::INSTALLER_STATUS_DEBUG);
        unlink($filename);
        continue;
      }
    }

    // Remove skipped files.
    foreach ($ignored_files as $skipped_file) {
      if (is_readable($skipped_file)) {
        unlink($skipped_file);
      }
    }

    // Remove empty directories.
    foreach ($dirs as $dir) {
      Files::rmdirRecursiveEmpty($dir);
    }

    // Src directory is now "clean" - copy it to dst directory.
    if (is_dir($src) && !Files::dirIsEmpty($src)) {
      Files::copyRecursive($src, $dst, 0755, FALSE);
    }

    // Special case for .env.local as it may exist.
    if (!file_exists($dst . '/.env.local')) {
      Files::copyRecursive($dst . '/.env.local.example', $dst . '/.env.local', 0755, FALSE);
    }
  }
}