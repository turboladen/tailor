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
    Then the output should match /Total Problems.*1/
    And the output should match /position:  <Position>/
    And the exit status should be 1

    @hard_tabs
    Scenarios: Hard tab
      | File                             | Position |
      | horizontal_whitespace/1/hard_tab | 2:0      |
