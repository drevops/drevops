<?php

namespace Drupal\Tests\ys_core\Functional;

/**
 * Class YsCoreExampleFunctionalTest.
 *
 * Example test case class.
 *
 * @group YsCore
 */
class YsCoreExampleFunctionalTest extends YsCoreFunctionalTestBase {

  /**
   * Tests addition.
   *
   * @dataProvider dataProviderAdd
   */
  public function testAdd($a, $b, $expected, $expectExceptionMessage = NULL) {
    if ($expectExceptionMessage) {
      $this->expectException(\Exception::class);
      $this->expectExceptionMessage($expectExceptionMessage);
    }

    // Replace below with a call to your class method.
    $actual = $a + $b;

    $this->assertEquals($expected, $actual);
  }

  /**
   * Data provider for testAdd().
   */
  public function dataProviderAdd() {
    return [
      [0, 0, 0],
      [1, 1, 2],
    ];
  }

}