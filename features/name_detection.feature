Feature: Name detection
  As a Ruby developer, I want to be able to detect improper class and method
  names so that I can fix them.

  @method_naming @good_files
  Scenario Outline: Method naming
    Given <File> exists without a newline at the end
    And my configuration file "config.yml" looks like:
    """
    ---
    :style:
      :vertical_spacing:
        :trailing_newlines: 0
      :names:
        :allow_camel_case_methods: false
    """
    When I run `tailor --debug --config config.yml <File>`
    Then the output should match /Total Problems.*0/
    And the exit status should be 0

  Scenarios: Good method naming
    | File                         |
    | naming/ok/single_word_method |
    | naming/ok/two_word_method    |

  @method_naming @bad_files

  Scenario Outline: Bad method naming
    Given <File> exists without a newline at the end
    And my configuration file "config.yml" looks like:
    """
    ---
    :style:
      :vertical_spacing:
        :trailing_newlines: 0
      :names:
        :allow_camel_case_methods: false
    """
    When I run `tailor --debug --config config.yml <File>`
    Then the output should match /Total Problems.*<Count>/
    And the output should match /position:  <Position>/
    And the exit status should be <Status>

  Scenarios: Bad method naming
    | File                                                 | Count | Position | Status |
    | naming/1/one_caps_camel_case_method                  | 1     | 1:4      | 1      |
    | naming/1/one_caps_camel_case_method_trailing_comment | 1     | 1:4      | 1      |
    
