Feature: Detect bad spacing around commas
  As a Ruby developer
  I want to detect bad spacing around commas in my code
  So that it's easy to read and maintain

  Scenario: More than 1 space after a comma
    Given a file with 1 space after a comma in a:
      | Type    |
      | comment |
      | method  |
      | Array   |
      | Hash    |
  
  Scenario: 0 spaces after a comma
    Given a file with 0 spaces after a comma in a:
      | Type    |
      | comment |
      | method  |
      | Array   |
      | Hash    |

  Scenario: 1 space after a comma
    Given a file with 1 space after a comma in a:
      | Type    |
      | comment |
      | method  |
      | Array   |
      | Hash    |

  Scenario: More than 0 spaces before a comma
    Given a file with more than 0 spaces before a comma in a:
      | Type    |
      | comment |
      | method  |
      | Array   |
      | Hash    |

  Scenario: 0 spaces before a comma
    Given a file with 0 spaces before a comma in a:
      | Type    |
      | comment |
      | method  |
      | Array   |
      | Hash    |
