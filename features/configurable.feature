Feature: Configurable
  As a Ruby developer
  I want to be able to configure tailor to my style likings
  So that tailor only detects the problems that I care about.

  Scenario: No config file exists
    Given a file named ".tailorrc" should not exist
    When I successfully run `tailor --config`
    Then the output should contain:
      """
      +---------------------------+------------------+
      |                Configuration                 |
      +---------------------------+------------------+
      |    Indentation                               |
      +---------------------------+------------------+
      |    spaces                 |    2             |
      |    allow_hard_tabs        |    false         |
      |    continuation_spaces    |    2             |
      +---------------------------+------------------+
      |    Vertical whitespace                       |
      +---------------------------+------------------+
      |    trailing_newlines      |    1             |
      +---------------------------+------------------+
      """
    And the exit status should be 0

  Scenario: Configuration file at ~/.tailorrc is valid YAML
    Given a file named ".tailorrc" with:
      """
      ---
      :indentation:
        :spaces: 5
      :vertical_whitespace:
        :trailing_newlines: 11
      """
    When I successfully run `tailor --config`
    Then the output should contain:
      """
      +-------------------------+------------------+
      |               Configuration                |
      +-------------------------+------------------+
      |    Indentation                             |
      +-------------------------+------------------+
      |    spaces               |    5             |
      +-------------------------+------------------+
      |    Vertical whitespace                     |
      +-------------------------+------------------+
      |    trailing_newlines    |    11            |
      +-------------------------+------------------+
      """

  Scenario: Pass in configuration file at runtime
    Given a file named "some_config.yml" with:
      """
      ---
      :indentation:
        :spaces: 7
      :vertical_whitespace:
        :trailing_newlines: 13
      """
    When I successfully run `tailor --config some_config.yml`
    Then the output should contain:
      """
      +-------------------------+------------------+
      |               Configuration                |
      +-------------------------+------------------+
      |    Indentation                             |
      +-------------------------+------------------+
      |    spaces               |    7             |
      +-------------------------+------------------+
      |    Vertical whitespace                     |
      +-------------------------+------------------+
      |    trailing_newlines    |    13            |
      +-------------------------+------------------+
      """


