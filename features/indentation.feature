@announce
Feature: Indentation check
  As a Ruby developer
  I want to check the indentation of my Ruby code
  So that I follow Ruby indentation conventions.

  Scenario: one
    Given a file named "my_class.rb" with:
      """
      require 'some_file'

      class MyClass
        include SomeModule
      end
      """
    When I successfully run `tailor my_class.rb`
    Then the output should contain "0 errors."
