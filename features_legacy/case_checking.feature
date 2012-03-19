Feature: Case checking
  In order to make sure certain words are upper or lower case as they should be
  As a Ruby developer
  I want to find out which files have words that aren't in the proper case
  
  Scenario: Method names that are camel-cased are detected
    Given I have a project directory "1_file_with_camel_case_method"
      And I have "1" file in my project
      And that file does not contain any "class" statements
      And the file contains only "1" "def" statement
      And the file contains a "method" that has a camel-cased name
    When I run the checker on the project
    Then the checker should tell me I have a camel-cased method name  

  Scenario: Method names that are snake-cased are not reported
    Given I have a project directory "1_file_with_snake_case_method"
      And I have "1" file in my project
      And that file does not contain any "class" statements
      And the file contains only "1" "def" statement
      And the file contains a "method" that has a snake-cased name
    When I run the checker on the project
    Then the checker shouldn't tell me the method name is camel-case

  Scenario: Class names that are camel-cased are not reported
    Given I have a project directory "1_file_with_camel_case_class"
      And I have "1" file in my project
      And the file contains only "1" "class" statement
      And the file contains a "class" that has a camel-cased name
    When I run the checker on the project
    Then the checker shouldn't tell me the class name is camel-case 

  Scenario: Class names that are snake-cased are detected
    Given I have a project directory "1_file_with_snake_case_class"
      And I have "1" file in my project
      And the file contains only "1" "class" statement
      And the file contains a "class" that has a snake-cased name
    When I run the checker on the project
    Then the checker should tell me the class name is not camel-case 
