Feature: Case checking
  In order to make sure certain words are upper or lower case as they should be
  As a Ruby developer
  I want to find out which files have words that aren't in the proper case
  
  Scenario: Method names that are camel-cased are detected
    Given I have a project directory "1_file_with_camel_case_method"
      And I have "1" file in my project
      And that file does not contain any "class" statements
      And the file contains only "1" "def" statement
      And the file contains a method that has a camel-cased name
    When I run the checker on the project
    Then the checker should tell me I have a camel-cased method name  
  
