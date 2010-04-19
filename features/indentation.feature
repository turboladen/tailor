Feature: Indentation
  In order to determine if my Ruby file is indented according to 
    2-space standards
  As a Ruby developer
  I want to find out which files have indentation problems,
    which lines those problems occur on,
    and how much indentation they're missing

  Scenario: A single class-less file in a project; 1 method, indented properly
    Given I have a project directory "1_good_simple_file"
      And I have "1" file in my project
      And that file does not contain any "class" statements
      And the file contains only "1" "def" statement
      And that file is indented properly
    When I run the checker on the project
    Then the checker should tell me my indentation is OK
  
  Scenario: A single class-less file with hard tabs
    Given I have a project directory "1_file_with_hard_tabs"
      And I have "1" file in my project
      And that file does not contain any "class" statements
      And the file contains only "1" "def" statement
      And that file contains lines with hard tabs
    When I run the checker on the project
    Then the checker should tell me each line that has a hard tab
  
