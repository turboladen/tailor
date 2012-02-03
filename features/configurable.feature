@announce
Feature: Configurable
  As a Ruby developer
  I want to be able to configure tailor to my style likings
  So that tailor only detects the problems that I care about.

  Scenario: No config file exists
    Given a file named ".tailor" should not exist
    When I successfully run `tailor --config`
    Then the output should contain:
      """
      +-----------------------+---------------+
      |             Configuration             |
      +-----------------------+---------------+
      |    Indentation                        |
      +-----------------------+---------------+
      |    spaces             |    2          |
      |    allow_hard_tabs    |    false      |
      +-----------------------+---------------+
      """
    And the exit status should be 0

  Scenario: Configuration file at ~/.tailor is valid YAML
    Given a file named ".tailor" with:
      """
      ---
      :indentation:
        :spaces: 7
        :special_param: false
      """
    When I successfully run `tailor --config`
    Then the output should match /spaces\s+|\s+7/
    And the output should match /special_param\s+|\s+false/
    And the exit status should be 0

