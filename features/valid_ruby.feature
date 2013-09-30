Feature: Valid Ruby
  As a Ruby developer, I want to check my project files to make sure they're
  valid Ruby, so when I see other tailor problems, I know why those problems
  might be there.

  Scenario: Extra 'end'
    Given a file named "extra_end.rb" with:
    """
    def a_method
      puts 'stuff'
    end
    end

    """
    When I run `tailor -d extra_end.rb`
    Then the output should match /TOTAL.*1/
    And the output should match /File contains invalid Ruby/
