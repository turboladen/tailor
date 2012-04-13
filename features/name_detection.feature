Feature: Name detection
  As a Ruby developer, I want to be able to detect improper class and method
  names so that I can fix them.

  Background:
    Given my configuration file ".tailor" looks like:
    """
    Tailor.config do |config|
      config.file_set do |style|
        style.trailing_newlines = 0
      end
    end
    """

  @method_naming @good_files
  Scenario Outline: Method naming
    Given <File> exists without a newline at the end
    When I run `tailor -d -c .tailor <File>`
    Then the output should match /Total Problems.*0/
    And the exit status should be 0

  Scenarios: Good method naming
    | File                         |
    | naming/ok/single_word_method |
    | naming/ok/two_word_method    |

  @method_naming @bad_files

  Scenario Outline: Bad method naming
    Given <File> exists without a newline at the end
    When I run `tailor -d -c .tailor <File>`
    Then the output should match /Total Problems.*<Count>/
    And the output should match /position:  <Position>/
    And the exit status should be 1

  Scenarios: Bad method naming
    | File                                                 | Count | Position |
    | naming/1/one_caps_camel_case_method                  | 1     | 1:4      |
    | naming/1/one_caps_camel_case_method_trailing_comment | 1     | 1:4      |

  @class_naming @good_files

  Scenario Outline: Good class naming
    Given <File> exists without a newline at the end
    When I run `tailor -d -c .tailor <File>`
    Then the output should match /Total Problems.*0/
    And the exit status should be 0

  Scenarios: Good class/module naming
    | File                         |
    | naming/ok/single_word_class  |
    | naming/ok/single_word_module |
    | naming/ok/two_word_class     |
    | naming/ok/two_word_module    |

  @class_naming @bad_files

  Scenario Outline: Bad class/module naming
    Given <File> exists without a newline at the end
    When I run `tailor -d -c .tailor <File>`
    Then the output should match /Total Problems.*<Count>/
    And the output should match /position:  <Position>/
    And the exit status should be 1

  Scenarios: Bad method naming
    | File                                      | Count | Position |
    | naming/1/one_screaming_snake_case_class   | 1     | 1:6      |
    | naming/1/one_screaming_snake_module_class | 1     | 1:7      |
    | naming/1/two_screaming_snake_case_class   | 1     | 1:6      |
    | naming/1/two_screaming_snake_module_class | 1     | 1:7      |
    

