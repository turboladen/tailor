Feature: Horizontal whitespace detection
  As a Ruby developer, I want to be able to detect horizontal whitespace
  problems so that I can fix them.

  @bad_files
  Scenario Outline: Detect hard tabs
    Given <File> exists without a newline at the end
    And my configuration file "testfile.yml" looks like:
    """
    ---
    :style:
      :indentation:
        :spaces: 2
      :vertical_whitespace:
        :trailing_newlines: 0
      :horizontal_whitespace:
        :allow_hard_tabs: false
    """
    When I run `tailor --debug --config testfile.yml <File>`
    Then the output should match /Total Problems.*<Count>/
    And the output should match /position:  <Position>/
    And the output should match /position:  <Position 2>/
    And the exit status should be 1

    @hard_tabs
    Scenarios: Hard tab
      | File                                           | Position | Position 2  | Count |
      | h_whitespace/1/hard_tab                        | 2:0      |             | 1     |
      | h_whitespace/1/hard_tab_with_spaces            | 3:0      |             | 1     |
      | h_whitespace/1/hard_tab_with_1_indented_space  | 3:0      |             | 1     |
      | h_whitespace/2/hard_tab_with_2_indented_spaces | 3:0      | 3:5         | 2     |
