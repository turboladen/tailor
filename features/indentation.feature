@wip
Feature: Indentation check
  As a Ruby developer
  I want to check the indentation of my Ruby code
  So that I follow Ruby indentation conventions.

  Scenario: No indentation problems with this project
    Given my configuration file ".tailor" looks like:
    """
    Tailor.config do |config|
      config.file_set do |style|
        style.trailing_newlines 0
      end
    end
    """
    When I successfully run `tailor -d -c .tailor ../../lib`
    Then the output should contain "problem count: 0"
    And the exit status should be 0
