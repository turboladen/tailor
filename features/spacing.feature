Feature: Spacing
  In order to determine if my Ruby file is spaced according to 
    standards
  As a Ruby developer
  I want to find out which files have spacing problems,
    which lines those problems occur on,
    and what type of spacing they're missing

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

  Scenario: A single file that has all lines with trailing whitespace
    Given I have a project directory "1_file_with_trailing_whitespace"
      And I have "1" file in my project
      And that file contains lines with trailing whitespace
    When I run the checker on the project
    Then the checker should tell me each line has trailing whitespace

  Scenario: A single file that has a comment and a code line 90 characters long
    Given I have a project directory "1_file_with_long_lines"
      And I have "1" file in my project
      And that file contains lines longer than 80 characters
    When I run the checker on the project
    Then the checker should tell me each line is too long
  
  Scenario: A single file that has a comment, method name, and statement without spaces after the commas
    Given I have a project directory "1_file_with_bad_comma_spacing"
      And I have "1" file in my project
      And that file contains a "comment" line without spaces after commas
      And that file contains a "method" line without spaces after commas
      And that file contains a "statement" line without spaces after commas
    When I run the checker on the project
    Then the checker should tell me each line has commas without spaces after them
  
  Scenario: A single file that has a comment, method name, and statement with > 1 spaces after the commas
    Given I have a project directory "1_file_with_bad_comma_spacing"
      And I have "1" file in my project
      And that file contains a "comment" line with > 1 spaces after commas
      And that file contains a "method" line with > 1 spaces after commas
      And that file contains a "statement" line with > 1 spaces after commas
    When I run the checker on the project
    Then the checker should tell me each line has commas with > 1 spaces after them
  
  Scenario: A single file that has a comment, method name, and statement with spaces before the commas
    Given I have a project directory "1_file_with_bad_comma_spacing"
      And I have "1" file in my project
      And that file contains a "comment" line with spaces before commas
      And that file contains a "method" line with spaces before commas
      And that file contains a "statement" line with spaces before commas
    When I run the checker on the project
    Then the checker should tell me each line has commas with spaces before them
  
