Feature: Continuous Integration
  As a Ruby developer, I want builds to fail when my project encounters tailor
  errors so I can be sure to fix those errors as soon as possible.

  Scenario: Warnings found, but not errors
    Given my configuration file ".tailor" looks like:
    """
    Tailor.config do |config|
      config.file_set do |style|
        style.trailing_newlines 0, level: :warn
      end
    end
    """
    And a file named "warnings.rb" with:
    """
    puts 'hi'
    
    
    """
    When I successfully run `tailor -d -c .tailor warnings.rb`
    Then the output should match /File has 2 trailing newlines/
    And the exit status should be 0
    
  Scenario: Errors found
    Given my configuration file ".tailor" looks like:
    """
    Tailor.config do |config|
      config.file_set do |style|
        style.trailing_newlines 0, level: :error
      end
    end
    """
    And a file named "errors.rb" with:
    """
    puts 'hi'
    
    
    """
    When I run `tailor -d -c .tailor errors.rb`
    Then the output should match /File has 2 trailing newlines/
    And the exit status should be 1

