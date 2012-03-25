Feature: Horizontal spacing detection
  As a Ruby developer, I want to be able to detect horizontal spacing
  problems so that I can fix them.

  @bad_files @hard_tabs
  Scenario Outline: Detect hard tabs
    Given <File> exists without a newline at the end
    And my configuration file "testfile.yml" looks like:
    """
    ---
    :style:
      :indentation:
        :spaces: 2
      :vertical_spacing:
        :trailing_newlines: 0
      :horizontal_spacing:
        :allow_hard_tabs: false
    """
    When I run `tailor --debug --config testfile.yml <File>`
    Then the output should match /Total Problems.*<Count>/
    And the output should match /position:  <Position>/
    And the output should match /position:  <Position 2>/
    And the exit status should be 1

  Scenarios: Hard tab
    | File                                        | Position | Position 2 | Count |
    | h_spacing/1/hard_tab                        | 2:0      |            | 1     |
    | h_spacing/1/hard_tab_with_spaces            | 3:0      |            | 1     |
    | h_spacing/1/hard_tab_with_1_indented_space  | 3:0      |            | 1     |
    | h_spacing/2/hard_tab_with_2_indented_spaces | 3:0      | 3:5        | 2     |

  @bad_files @long_lines
  Scenario Outline: Detect long lines
    Given <File> exists without a newline at the end
    And my configuration file "testfile.yml" looks like:
    """
    ---
    :style:
      :vertical_spacing:
        :trailing_newlines: 0
      :horizontal_spacing:
        :line_length: 80
    """
    When I run `tailor --debug --config testfile.yml <File>`
    Then the output should match /Total Problems.*<Count>/
    And the output should match /position:  <Position>/
    And the exit status should be 1

  Scenarios:
    | File                                | Position | Count |
    | h_spacing/1/long_line_no_newline    | 1:81     | 1     |
    | h_spacing/1/long_line_newline_at_82 | 1:81     | 1     |

  @good_files @long_lines

  Scenario Outline: Lines under long-line threshold
    Given <File> exists without a newline at the end
    And my configuration file "testfile.yml" looks like:
    """
    ---
    :style:
      :vertical_spacing:
        :trailing_newlines: 0
      :horizontal_spacing:
        :allow_trailing_spaces: true
        :line_length: 80
    """
    When I run `tailor --debug --config testfile.yml <File>`
    Then the output should match /Total Problems.*0/
    And the exit status should be 0

  Scenarios:
    | File                                  |
    | h_spacing/ok/short_line_no_newline    |
    | h_spacing/ok/short_line_newline_at_81 |

  @bad_files @trailing_spaces

  Scenario Outline: Lines with trailing spaces
    Given <File> exists without a newline at the end
    And my configuration file "testfile.yml" looks like:
    """
    ---
    :style:
      :vertical_spacing:
        :trailing_newlines: 0
      :horizontal_spacing:
        :allow_trailing_spaces: false
    """
    When I run `tailor --debug --config testfile.yml <File>`
    Then the output should match /Total Problems.*<Count>/
    And the output should match /position:  <Position>/
    And the exit status should be 1

  Scenarios:
    | File                                         | Count | Position |
    | h_spacing/1/empty_line_with_spaces           | 1     | 1:2      |
    | h_spacing/1/empty_line_with_spaces_in_method | 1     | 2:2      |
    | h_spacing/1/trailing_spaces_on_def           | 1     | 1:10     |

