@wip
Feature: Indentation check
  As a Ruby developer
  I want to check the indentation of my Ruby code
  So that I follow Ruby indentation conventions.

  Scenario: No indentation problems with this project
    Given my configuration file "testfile.yml" looks like:
    """
    ---
    :indentation:
      :spaces: 2
    :vertical_spacing:
      :trailing_newlines: 1
    :horizontal_spacing:
      :allow_trailing_spaces: true
    """
    When I successfully run `tailor --config testfile.yml ../../lib`
    Then the output should contain "problem count: 0"
    And the exit status should be 0
