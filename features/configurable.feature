Feature: Configurable
  As a Ruby developer
  I want to be able to configure tailor to my style likings
  So that tailor only detects the problems that I care about.

  Scenario: Print configuration when no config file exists
    Given a file named ".tailor" should not exist
    When I successfully run `tailor --show-config`
    Then the output should match /Configuration/
    And the output should match /Formatters.+|.+text.+|/
    And the output should match /Label.+|.+default.+|/
    And the output should match /Style.+|/
    And the output should match /File List.+|/
    And the exit status should be 0

  Scenario: Print configuration when .tailor exists
    Given a file named ".tailorrc" with:
      """
      Tailor::Configuration::Style.define_property :some_ruler

      Tailor.config do |config|
        config.formatters 'test'
        config.file_set 'test/**/*.rb' do |style|
          style.some_ruler 1234
        end
      end
      """
    When I successfully run `tailor --show-config`
    Then the output should match /Formatters.+|.+test.+|/
    And the output should match /some_ruler.+|.+1234.+|/

  @wip
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


