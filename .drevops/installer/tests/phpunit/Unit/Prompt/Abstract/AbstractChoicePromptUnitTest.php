<?php

namespace Drevops\Installer\Tests\Unit\Prompt\Abstract;

use DrevOps\Installer\Bag\Answers;
use DrevOps\Installer\Bag\Config;
use DrevOps\Installer\Prompt\AbstractChoicePrompt;
use Drevops\Installer\Tests\Unit\Prompt\PromptUnitTestCase;
use Symfony\Component\Console\Question\Question;

/**
 * @coversDefaultClass \DrevOps\Installer\Prompt\AbstractChoicePrompt
 */
class AbstractChoicePromptUnitTest extends PromptUnitTestCase {

  /**
   * @covers ::__construct
   */
  public function testConstructor() {
    $prompt = new FilledChoicePromptFixture($this->io());
    $this->assertInstanceOf(AbstractChoicePrompt::class, $prompt);
  }

  /**
   * @covers ::title
   */
  public function testTitle() {
    $prompt = new FilledChoicePromptFixture($this->io());
    $this->assertEquals('Fixture title', $prompt::title());
  }

  /**
   * @covers ::title
   */
  public function testTitleErroneous() {
    $prompt = new ErroneousChoicePromptFixture($this->io());
    $this->expectException(\Exception::class);
    $this->expectExceptionMessage('The question title is not defined.');
    $prompt::title();
  }

  /**
   * @covers ::question
   */
  public function testQuestion() {
    $prompt = new FilledChoicePromptFixture($this->io());
    $this->assertEquals('Fixture question', $prompt::question());
  }

  /**
   * @covers ::question
   */
  public function testQuestionErroneous() {
    $prompt = new ErroneousChoicePromptFixture($this->io());
    $this->expectException(\Exception::class);
    $this->expectExceptionMessage('The question text is not defined.');
    $prompt::question();
  }

  /**
   * @covers ::getFormattedQuestion
   */
  public function testGetFormattedQuestion() {
    $prompt = new FilledChoicePromptFixture($this->io());
    $this->assertEquals('Fixture question', $prompt::getFormattedQuestion('val1'));
  }

  /**
   * @covers ::getFormattedQuestion
   */
  public function testGetFormattedQuestionErroneous() {
    $prompt = new ErroneousChoicePromptFixture($this->io());
    $this->expectException(\Exception::class);
    $this->expectExceptionMessage('The question text is not defined.');
    $prompt::getFormattedQuestion('val1');
  }

  /**
   * @covers ::getFormattedValue
   */
  public function testGetFormattedValue() {
    $prompt = new FilledChoicePromptFixture($this->io());
    $this->assertEquals('val1', $prompt::getFormattedValue('val1'));
  }

  /**
   * @covers ::getFormattedValue
   */
  public function testGetFormattedValueErroneous() {
    $prompt = new ErroneousChoicePromptFixture($this->io());
    $this->assertEquals('val1', $prompt::getFormattedValue('val1'));
  }

  /**
   * @covers ::defaultValue
   */
  public function testDefaultValue() {
    $prompt = new FilledChoicePromptFixture($this->io());
    $actual = $this->callProtectedMethod($prompt, 'defaultValue', [Config::getInstance(), Answers::getInstance()]);
    // Value defaults to the key of the first choice starting at 1.
    $this->assertEquals(1, $actual);
  }

  /**
   * @covers ::discoveredValue
   */
  public function testDiscoveredValue() {
    $prompt = new FilledChoicePromptFixture($this->io());
    $actual = $this->callProtectedMethod($prompt, 'discoveredValue', [Config::getInstance(), Answers::getInstance()]);
    $this->assertEquals(NULL, $actual);
  }

  /**
   * @covers ::normalizer
   */
  public function testNormalizer() {
    $prompt = new FilledChoicePromptFixture($this->io());
    $actual = $this->callProtectedMethod($prompt, 'normalizer', ['val1', Config::getInstance(), Answers::getInstance()]);
    $this->assertEquals('val1', $actual);

    $actual = $this->callProtectedMethod($prompt, 'normalizer', [['val1', 'val2'], Config::getInstance(), Answers::getInstance()]);
    $this->assertEquals(['val1', 'val2'], $actual);
  }

  /**
   * @covers ::valueNormalizer
   * @dataProvider dataProviderValueNormalizer
   */
  public function testValueNormalizer($value, $is_multiselect, $expected) {
    if ($is_multiselect) {
      $prompt = new FilledMultiChoicePromptFixture($this->io());
    }
    else {
      $prompt = new FilledChoicePromptFixture($this->io());
    }
    $actual = $this->callProtectedMethod($prompt, 'valueNormalizer', [$value, Config::getInstance(), Answers::getInstance()]);
    $this->assertEquals($expected, $actual);
  }

  public static function dataProviderValueNormalizer() {
    return [
      // Single select.
      [NULL, FALSE, NULL],
      ['', FALSE, NULL],
      [',', FALSE, NULL],
      [', ', FALSE, NULL],
      [' , ', FALSE, NULL],
      ['  , ', FALSE, NULL],
      ['  , , ', FALSE, NULL],
      [',,,', FALSE, NULL],
      [[], FALSE, NULL],
      [[[], []], FALSE, NULL],
      [['', ''], FALSE, NULL],

      ['choice1', FALSE, 'choice1'],
      ['choice1,choice2', FALSE, 'choice1'],
      ['choice1, choice2', FALSE, 'choice1'],
      [['choice1'], FALSE, 'choice1'],
      [['choice1', 'choice2'], FALSE, 'choice1'],

      ['1', FALSE, 'choice1'],
      ['choice1,1', FALSE, 'choice1'],
      ['1,choice2', FALSE, 'choice1'],
      ['1, 2', FALSE, 'choice1'],
      [[1], FALSE, 'choice1'],
      [[1, 'choice2'], FALSE, 'choice1'],

      // Multi select.
      [NULL, TRUE, NULL],
      ['', TRUE, NULL],
      [',', TRUE, NULL],
      [', ', TRUE, NULL],
      [' , ', TRUE, NULL],
      ['  , ', TRUE, NULL],
      ['  , , ', TRUE, NULL],
      [',,,', TRUE, NULL],
      [[], TRUE, NULL],
      [[[], []], TRUE, NULL],
      [['', ''], TRUE, NULL],

      ['choice1', TRUE, ['choice1']],
      ['choice1,choice2', TRUE, ['choice1', 'choice2']],
      ['choice1, choice2', TRUE, ['choice1', 'choice2']],
      [['choice1'], TRUE, ['choice1']],
      [['choice1', 'choice2'], TRUE, ['choice1', 'choice2']],

      ['1', TRUE, ['choice1']],
      ['choice1,1', TRUE, ['choice1']],
      ['1,choice2', TRUE, ['choice1', 'choice2']],
      ['1, 2', TRUE, ['choice1', 'choice2']],
      [[1], TRUE, ['choice1']],
      [[1, 'choice2'], TRUE, ['choice1', 'choice2']],

      ['2,1', TRUE, ['choice1', 'choice2']],
    ];
  }

  /**
   * @covers ::validator
   */
  public function testValidator() {
    $prompt = new FilledChoicePromptFixture($this->io());
    $val_before = 'choice1';
    $val_after = $val_before;
    $this->callProtectedMethod($prompt, 'validator', [$val_before, Config::getInstance(), Answers::getInstance()]);
    $this->assertEquals($val_after, $val_before);
  }

  /**
   * @covers ::validator
   */
  public function testValidatorInvalidValueException() {
    $prompt = new FilledChoicePromptFixture($this->io());
    $val_before = [static::MACHINE_NAME_INVALID];
    $val_after = $val_before;

    $this->expectException(\Exception::class);
    $this->expectExceptionMessage('The name must contain only lowercase letters, numbers, and underscores.');

    $this->callProtectedMethod($prompt, 'validator', [$val_before, Config::getInstance(), Answers::getInstance()]);
    $this->assertEquals($val_after, $val_before);
  }

  /**
   * @covers ::validator
   */
  public function testValidatorInvalidValueFromListException() {
    $prompt = new FilledChoicePromptFixture($this->io());
    $val_before = ['choice4'];
    $val_after = $val_before;

    $this->expectException(\Exception::class);
    $this->expectExceptionMessage('The following values are not valid: choice4');

    $this->callProtectedMethod($prompt, 'validator', [$val_before, Config::getInstance(), Answers::getInstance()]);
    $this->assertEquals($val_after, $val_before);
  }

  /**
   * @covers ::validator
   */
  public function testValidatorSingleValueException() {
    $this->expectException(\Exception::class);
    $this->expectExceptionMessage('Only one value is allowed.');

    $prompt = new FilledChoicePromptFixture($this->io());
    $val_before = ['choice1', 'choice2'];
    $val_after = $val_before;
    $this->callProtectedMethod($prompt, 'validator', [$val_before, Config::getInstance(), Answers::getInstance()]);
    $this->assertEquals($val_after, $val_before);
  }

  /**
   * @covers ::processQuestion
   */
  public function testProcessQuestion() {
    $question_before = new Question('fixture question');
    $question_after = clone $question_before;

    $prompt = new FilledChoicePromptFixture($this->io());
    $this->callProtectedMethod($prompt, 'processQuestion', [$question_before, Config::getInstance(), Answers::getInstance()]);
    $this->assertEquals($question_before, $question_after);

    $this->callProtectedMethod($prompt, 'processQuestion', [$question_before, Config::getInstance(), Answers::getInstance()]);
    $this->assertEquals($question_before, $question_after);
  }

  /**
   * @covers ::processAnswer
   */
  public function testProcessAnswer() {
    $answer_before = 'val before';
    $answer_after = $answer_before;

    $prompt = new FilledChoicePromptFixture($this->io());
    $this->callProtectedMethod($prompt, 'processAnswer', [$answer_before, Config::getInstance(), Answers::getInstance()]);
    $this->assertEquals($answer_before, $answer_after);
  }

  /**
   * @covers ::createQuestion
   */
  public function testCreateQuestion() {
    $prompt = new FilledChoicePromptFixture($this->io());

    $actual = $this->callProtectedMethod($prompt, 'createQuestion', ['question text', 'default value']);
    $this->assertInstanceOf(Question::class, $actual);
    $this->assertFalse($actual->isMultiselect());

    $actual = $this->callProtectedMethod($prompt, 'createQuestion', ['question text', ['default value1', 'default value2']]);
    $this->assertInstanceOf(Question::class, $actual);
    $this->assertFalse($actual->isMultiselect());

    // Mutiselect.
    $prompt = new FilledMultiChoicePromptFixture($this->io());

    $actual = $this->callProtectedMethod($prompt, 'createQuestion', ['question text', 'default value']);
    $this->assertInstanceOf(Question::class, $actual);
    $this->assertTrue($actual->isMultiselect());

    $actual = $this->callProtectedMethod($prompt, 'createQuestion', ['question text', ['default value1', 'default value2']]);
    $this->assertInstanceOf(Question::class, $actual);
    $this->assertTrue($actual->isMultiselect());
  }

  /**
   * @covers ::makeChoicesReindex
   */
  public function testMakeChoicesReindex() {
    $prompt = new FilledChoicePromptFixture($this->io());
    $actual = $this->callProtectedMethod($prompt, 'makeChoicesReindex', [['a', 'b', 'c']]);
    $this->assertEquals([1 => 'a', 2 => 'b', 3 => 'c'], $actual);
  }

  /**
   * @runInSeparateProcess
   * @covers ::compileDefaultValue
   * @dataProvider dataProviderCompileDefaultValue
   */
  public function testCompileDefaultValue($default_value, $discovered_value, $normalizer_value, $value_normalizer_value, $value_validator, $expected) {
    $prompt = $this->prepareMock(AbstractChoicePrompt::class, [
      'defaultValue' => $default_value,
      'discoveredValue' => $discovered_value,
      'normalizer' => function ($value) use ($normalizer_value) {
        return $normalizer_value ?: $value;
      },
      'valueNormalizer' => function ($value) use ($value_normalizer_value) {
        return $value_normalizer_value ?: $value;
      },
      'validator' => function () use ($value_validator) {
        if (str_contains($value_validator, 'Exception')) {
          throw new \Exception($value_validator);
        }
      },
    ]);

    $actual = $this->callProtectedMethod($prompt, 'compileDefaultValue', [Config::getInstance(), Answers::getInstance()]);
    $this->assertEquals($expected, $actual);
  }

  public static function dataProviderCompileDefaultValue() {
    return [
      // Default value is NULL.
      [NULL, NULL, NULL, NULL, NULL, NULL],

      // Default value is set.
      ['default', NULL, NULL, NULL, NULL, 'default'],

      // Default value is set and discovered.
      ['default', 'discovered', NULL, NULL, NULL, 'discovered'],

      // Default value is not set, but discovered.
      [NULL, 'discovered', NULL, NULL, NULL, 'discovered'],

      // Default value is set and discovered, and also normalised.
      ['default', 'discovered', 'discovered_normalised', NULL, NULL, 'discovered_normalised'],

      // Default value is set and discovered, and also normalised and then
      // converted.
      ['default', 'discovered', 'discovered_normalised', 'discovered_normalised_converted', NULL, 'discovered_normalised_converted'],

      // Default value is set and discovered, and also normalised and then
      // converted, but invalid.
      ['default', 'discovered', 'discovered_normalised', 'discovered_normalised_converted', 'Validation Exception', 'default'],

      // Default value is NOT set and discovered, and also normalised and then
      // converted, but invalid.
      [NULL, 'discovered', 'discovered_normalised', 'discovered_normalised_converted', 'Validation Exception', NULL],
    ];
  }

  /**
   * @runInSeparateProcess
   * @covers ::ask
   * @dataProvider dataProviderAsk
   */
  public function testAsk($default_value, $normalizer_value, $value_normalizer_value, $value_validator, $expected_answer) {
    $expect_exception = str_contains($value_validator, 'Exception');

    $prompt = $this->prepareMock(FilledChoicePromptFixture::class, [
      'defaultValue' => $default_value,
      'normalizer' => function ($value) use ($normalizer_value) {
        return $normalizer_value ?: $value;
      },
      'valueNormalizer' => function ($value) use ($value_normalizer_value) {
        return $value_normalizer_value ?: $value;
      },
      'validator' => function () use ($value_validator, $expect_exception) {
        if ($expect_exception) {
          throw new \Exception($value_validator);
        }
      },
    ],
      [$this->io($expected_answer)]
    );

    if ($expect_exception) {
      $this->expectException(\Exception::class);
    }

    $actual = $prompt->ask(Config::getInstance(), Answers::getInstance());

    if (!$expect_exception) {
      $this->assertEquals($expected_answer, $actual);
    }
  }

  public static function dataProviderAsk() {
    return [
      // Default value is NULL.
      [NULL, NULL, NULL, NULL, static::DEFAULT_ANSWER],

      // Default value is set.
      ['default', NULL, NULL, NULL, 'default'],

      // Default value is set and discovered.
      ['default', 'discovered', NULL, NULL, 'discovered'],

      // Default value is not set, but discovered.
      [NULL, 'discovered', NULL, NULL, 'discovered'],

      // Default value is set and discovered, and also normalised.
      ['default', 'discovered', 'discovered_normalised', NULL, 'discovered_normalised'],

      // Default value is set and discovered, and also normalised, but invalid.
      ['default', 'discovered', 'discovered_normalised', 'Validation Exception', NULL],

      // Default value is NOT set and discovered, and also normalised, but invalid.
      [NULL, 'discovered', 'discovered_normalised', 'Validation Exception', NULL],
    ];
  }


}


class ErroneousChoicePromptFixture extends AbstractChoicePrompt {

  public static function choices() {
  }

}

class FilledChoicePromptFixture extends AbstractChoicePrompt {

  public static function title() {
    return 'Fixture title';
  }

  public static function question() {
    return 'Fixture question';
  }

  public static function choices() {
    return [
      'choice1',
      'choice2',
      'choice3',
    ];
  }

}

class FilledMultiChoicePromptFixture extends FilledChoicePromptFixture {

  protected $isMultiselect = TRUE;

}