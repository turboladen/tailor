@indentation
Feature: Indentation check on bad files with trailing newlines

  @trailing_newlines, @bad_files
  Scenario Outline: Detect singular problems on poorly indented files with newlines at the end
    Given <File> exists with a newline at the end
    When I run `tailor -d <File>`
    Then the output should match /Total Problems.*1/
    And the exit status should be 1

  Scenarios: 1 problem with classes
    | File                                           |
    | indent/1/class_indented_end                    |
    | indent/1/class_method_def_using_self_outdented |

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
