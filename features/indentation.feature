@announce
Feature: Indentation check
  As a Ruby developer
  I want to check the indentation of my Ruby code
  So that I follow Ruby indentation conventions.

# Notice the newline after the end keyword--line checking only occurs when
# we've hit the end of the line; since there's no signal for this, the
# error doesn't get caught unless there's that newline there.

  Scenario Outline: Don't detect problems on properly indented files
    Given <File> exists
    When I successfully run `tailor <File>`
    Then the output should contain "problem count: 0"
    And the exit status should be 0

  Scenarios: Good class uses
    | File                     |
    | indent/ok/class          |
    | indent/ok/nested_class   |
    | indent/ok/class_empty    |
    | indent/ok/one_line_class |

  Scenarios: Good single-line statement uses
    | File                                    |
    | indent/ok/class_singlestatement         |
    | indent/ok/require_class_singlestatement |

  Scenarios: Good def uses
    | File                                                |
    | indent/ok/def                                       |
    | indent/ok/def_empty                                 |
    | indent/ok/nested_def                                |
    | indent/ok/require_class_singlestatement_def         |
    | indent/ok/require_class_singlestatement_def_content |

  Scenario Outline: Detect singular problems on poorly indented files
    Given <File> exists
    When I run `tailor <File>`
    Then the output should contain "problem count: 1"
    And the exit status should be 1

  Scenarios: 1 problem with classes
    | File                        |
    | indent/1/class_indented_end |

  Scenarios: 1 problem with single-line statement
    | File                                     |
    | indent/1/class_indented_singlestatement  |
    | indent/1/class_outdented_singlestatement |
    | indent/1/class_def_outdented_content     |

  Scenarios: 1 problem with def
    | File                                     |
    | indent/1/def_indented_end                |
    | indent/1/def_content_indented_end        |
    | indent/1/class_def_content_outdented_end |

