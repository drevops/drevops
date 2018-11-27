<?php

/**
 * Class MySiteDrupalTestCase.
 */
abstract class MySiteDrupalTestCase extends MySiteTestCase {

  /**
   * Bootstrap site for use in tests.
   */
  protected function bootstrapDrupal() {
    if (!defined('DRUPAL_ROOT')) {
      $docroot_path = sprintf('%s%s%s', getcwd(), DIRECTORY_SEPARATOR, 'docroot');
      $_SERVER['HTTP_HOST'] = 'mysite.docker.amazee.io';
      // @codingStandardsIgnoreStart
      $_SERVER['REMOTE_ADDR'] = '127.0.0.1';
      // @codingStandardsIgnoreEnd
      define('DRUPAL_ROOT', $docroot_path);
      set_include_path($docroot_path . PATH_SEPARATOR . get_include_path());
      require_once DRUPAL_ROOT . '/includes/bootstrap.inc';
      drupal_bootstrap(DRUPAL_BOOTSTRAP_FULL);
    }
  }

  /**
   * {@inheritdoc}
   */
  public function setUp() {
    $this->bootstrapDrupal();
  }

}
