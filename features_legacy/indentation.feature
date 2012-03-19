Feature: Indentation

  Scenario: A single file project with every in/outdent expression, indented properly
    Given I have a project directory "1_long_file_with_indentation"
      And I have 1 file in my project
      And that file is indented properly
    When I run the checker on the project
    Then the checker should tell me my indentation is OK

  Scenario: A single file that's indented properly (OLD)
    Given I have a project directory "1_good_simple_file"
      And I have 1 file in my project
      And the indentation of that file starts at level 0
      And the line 1 is a "class" statement
      And the line 2 is a "def" statement
    When I run tailor on the file
    Then tailor tells me there are no problems

  Scenario: A single file that's indented properly
    Given I have a file that looks like:-
    """
    class Thing
      def a_method
        puts "hi"
      end
    end
    """
    When I run tailor on the file
    Then tailor tells me there are no problems

