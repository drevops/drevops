<?php

namespace DrevOps\Installer\Prompt\Concrete;

use DrevOps\Installer\Bag\Answers;
use DrevOps\Installer\Bag\Config;
use DrevOps\Installer\Prompt\AbstractPrompt;
use Symfony\Component\Console\Question\Question;

class ProceedDrevopsInstallPrompt extends AbstractPrompt {

  const ID = 'proceed_drevops_install';

  /**
   * {@inheritdoc}
   */
  public static function title() {
    return 'Proceed with installation';
  }

  /**
   * {@inheritdoc}
   */
  public static function question() {
    return sprintf('Proceed with installing DrevOps?');
  }

  /**
   * {@inheritdoc}
   */
  protected function defaultValue(Config $config, Answers $answers): mixed {
    return NULL;
  }

  /**
   * {@inheritdoc}
   */
  protected function processQuestion(Question $question, Config $config, Answers $answers): void {
    parent::processQuestion($question, $config, $answers);

    // Set a custom validator to always require and input.
    // This is to prevent the user from accidentally skipping or running
    // the installation because there are too many questions.
    $question->setValidator(function ($value) {
      $value = $value ? strtolower($value) : $value;

      if (!in_array($value, ['y', 'n'])) {
        throw new \RuntimeException('Please answer with "y" or "n".');
      }

      return (bool) preg_match('/^y/i', $value);
    });
  }

  /**
   * {@inheritdoc}
   */
  public static function getFormattedQuestion(mixed $default): string {
    return sprintf('<bold>%s</bold> [<comment>y/n</comment>]', static::question());
  }

}