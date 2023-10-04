<?php

namespace DrevOps\Installer\Tests\Unit\Utils;

use DrevOps\Installer\Utils\ConstantsLoader;
use PHPUnit\Framework\TestCase;

/**
 * @coversDefaultClass \DrevOps\Installer\Utils\ConstantsLoader
 */
class ConstantsLoaderTest extends TestCase {

  /**
   * @covers ::load
   */
  public function testLoadWithoutPrefix() {
    $result = ConstantsLoader::load(ConstantsTestClass::class);

    $expected = [
      'TEST_CONST_1' => 'value1',
      'TEST_CONST_2' => 'value2',
    ];

    $this->assertSame($expected, $result);
  }

  /**
   * @covers ::load
   */
  public function testLoadWithPrefixKey() {
    $result = ConstantsLoader::load(ConstantsPrefixedTestClass::class, 'PREFIX');

    $expected = [
      'PREFIX_1' => 'valueWithPrefix1',
      'PREFIX_2' => 'valueWithPrefix2',
    ];

    $this->assertSame($expected, $result);
  }

  /**
   * @covers ::load
   */
  public function testLoadWithPrefixValue() {
    $result = ConstantsLoader::load(ConstantsPrefixedTestClass::class, 'valueWithPrefix', FALSE);

    $expected = [
      'PREFIX_1' => 'valueWithPrefix1',
      'PREFIX_2' => 'valueWithPrefix2',
    ];

    $this->assertSame($expected, $result);
  }

  /**
   * @covers ::load
   */
  public function testLoadWithEmptyClass() {
    $result = ConstantsLoader::load(ConstantsEmptyTestClass::class);

    $this->assertEquals([], $result);
  }

}

// Define a mock class with constants for testing
class ConstantsTestClass {

  const TEST_CONST_1 = 'value1';

  const TEST_CONST_2 = 'value2';
}

// Define a mock class with constants for testing
class ConstantsPrefixedTestClass {

  const PREFIX_2 = 'valueWithPrefix2';

  const PREFIX_1 = 'valueWithPrefix1';

  const WITHOUT_PREFIX = 'valueWithoutPrefix';
}

// Define a mock empty class for testing
class ConstantsEmptyTestClass {

}