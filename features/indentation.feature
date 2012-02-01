@announce
Feature: Indentation check
  As a Ruby developer
  I want to check the indentation of my Ruby code
  So that I follow Ruby indentation conventions.

  @no_problems
  Scenario: File without problems, using require and class
    Given a file named "my_class.rb" with:
      """
      require 'some_file'

      class MyClass
        include SomeModule
      end
      """
    When I successfully run `tailor my_class.rb`
    Then the output should contain "0 errors."

  @problems
  Scenario: Class keyword indented 1 space
    Given a file named "my_class.rb" with:
      """
      require 'some_file'

       class MyClass
        include SomeModule
      end
      """
    When I successfully run `tailor my_class.rb`
    Then the output should contain "1 error."

