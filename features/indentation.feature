@announce
Feature: Indentation check
  As a Ruby developer
  I want to check the indentation of my Ruby code
  So that I follow Ruby indentation conventions.

# Notice the newline after the end keyword--line checking only occurs when
# we've hit the end of the line; since there's no signal for this, the
# error doesn't get caught unless there's that newline there.

  Scenario Outline: new
    Given <File> exists
    When I successfully run `tailor <File>`
    Then the output should contain "problem count: 0"
    And the exit status should be 0

  Examples: Focus on class
    | File                                        |
    | indent/ok/class                             |
    | indent/ok/nested_class                      |
    | indent/ok/class_empty                       |
    | indent/ok/class_include                     |
    | indent/ok/require_class_include             |
    | indent/ok/require_class_include_def         |
    | indent/ok/require_class_include_def_content |

  Examples: Focus on def
    | File                 |
    | indent/ok/def        |
    | indent/ok/def_empty  |
    | indent/ok/nested_def |

