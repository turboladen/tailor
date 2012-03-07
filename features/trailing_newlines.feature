Feature: Trailing newlines
  As a Ruby developer
  I want to check my Ruby files for trailing newlines
  Because all of my files should have the same number of these

  @bad_files
  Scenario: Detect lack of newlines
    Given a file named "not_enough_newlines.rb" with:
      """
      def a_method
        puts 'hi'
      end
      """
    When I run `tailor .`
    Then the output should contain "problem count: 1"
    And the output should contain "0 trailing newlines, but should have 1"

  @bad_files
  Scenario: Detect too many newlines
    Given a file named "too_many_newlines.rb" with:
      """
      def a_method
        puts 'hi'
      end


      """
    When I run `tailor .`
    Then the output should contain "problem count: 1"
    And the output should contain "2 trailing newlines, but should have 1"

  @good_files
  Scenario: Doesn't report problem when meeting criteria
    Given a file named "good_file.rb" with:
      """
      def a_method
        puts 'hi'
      end

      """
    When I run `tailor .`
    Then the output should contain "problem count: 0"
