<?php

namespace DrevOps\Installer\Prompt\Concrete;

use DrevOps\Installer\Bag\Answers;
use DrevOps\Installer\Bag\Config;
use DrevOps\Installer\Prompt\AbstractChoicePrompt;
use DrevOps\Installer\Utils\DotEnv;
use DrevOps\Installer\Utils\Env;

class DatabaseStoreTypePrompt extends AbstractChoicePrompt {

  const CHOICE_FILE = 'file';

  const CHOICE_DOCKER_IMAGE = 'docker_image';

  const ID = 'database_store_type';

  /**
   * {@inheritdoc}
   */
  public static function title() {
    return 'Database store type';
  }

  /**
   * {@inheritdoc}
   */
  public static function question() {
    return ' When developing locally, do you want to import the database dump from the file or store it imported in the docker image for faster builds?';
  }

  /**
   * {@inheritdoc}
   */
  public static function choices() {
    return [
      self::CHOICE_FILE,
      self::CHOICE_DOCKER_IMAGE,
    ];
  }

  /**
   * {@inheritdoc}
   */
  protected function discoveredValue(Config $config, Answers $answers): mixed {
    return DotEnv::getValueFromDstDotenv($config->getDstDir(), Env::DB_DOCKER_IMAGE);
  }

}