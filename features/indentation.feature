Feature: Indentation check
  As a Ruby developer
  I want to check the indentation of my Ruby code
  So that I follow Ruby indentation conventions.

  @good_files
  Scenario Outline: Don't detect problems on properly indented files with no newlines at the end
    Given <File> exists with a newline at the end
    And my configuration file "testfile.yml" looks like:
    """
      ---
      :indentation:
        :spaces: 2
      :vertical_whitespace:
        :trailing_newlines: 0
      """
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

  Scenarios: Good multi-line statement uses
    | File                                               |
    | indent/ok/assignment_addition_multistatement       |
    | indent/ok/assignment_hash_multistatement           |
    | indent/ok/assignment_array_multistatement          |
    | indent/ok/assignment_paren_multistatement          |
    | indent/ok/assignment_twolevel_hash_multistatement  |
    | indent/ok/assignment_twolevel_array_multistatement |
    | indent/ok/assignment_twolevel_paren_multistatement |
    | indent/ok/method_call_multistatement               |

  Scenarios: Good def uses
    | File                                                |
    | indent/ok/def                                       |
    | indent/ok/def_empty                                 |
    | indent/ok/nested_def                                |
    | indent/ok/require_class_singlestatement_def         |
    | indent/ok/require_class_singlestatement_def_content |

  Scenarios: 'if' as modifier
    | File                             |
    | indent/ok/if_modifier            |
    | indent/ok/def_return_if_modifier |

  Scenarios: 'unless' as modifier
    | File                                 |
    | indent/ok/unless_modifier            |
    | indent/ok/def_return_unless_modifier |

  @trailing_newlines, @good_files
  Scenario Outline: Don't detect problems on properly indented files with newlines at the end
    Given <File> exists with a newline at the end
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

  Scenarios: 'if' as modifier
    | File                             |
    | indent/ok/if_modifier            |
    | indent/ok/def_return_if_modifier |

  Scenarios: 'unless' as modifier
    | File                                 |
    | indent/ok/unless_modifier            |
    | indent/ok/def_return_unless_modifier |

  @bad_files
  Scenario Outline: Detect singular problems on poorly indented files
    Given <File> exists with a newline at the end
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

  @trailing_newlines, @bad_files
  Scenario Outline: Detect singular problems on poorly indented files with newlines at the end
    Given <File> exists with a newline at the end
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

