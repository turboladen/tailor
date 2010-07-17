Feature: Indentation

  Scenario: A single file project with every in/outdent expression, indented properly
    Given I have a project directory "1_long_file_with_indentation"
      And I have 1 file in my project
      And that file is indented properly
    When I run the checker on the project
    Then the checker should tell me my indentation is OK

  Scenario: A single file that's indented properly
    Given I have a project directory "1_good_simple_file"
      And I have 1 file in my project
      And the indentation of that file starts at level 0
      And the line 1 is a "class" statement
      And the line 2 is a "def" statement
    When I run the checker on the project
    Then the level of line 1 should be 0.0
      And the level of line 2 should be 1.0
      And the level of line 3 should be 2.0
      And the level of line 4 should be 1.0
      And the level of line 5 should be 0.0
    
