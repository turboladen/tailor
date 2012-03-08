Feature: Indentation check on bad fails without trailing newlines

  @bad_files
  Scenario Outline: Detect singular problems on poorly indented files
    Given <File> exists without a newline at the end
    And my configuration file "testfile.yml" looks like:
    """
    ---
    :indentation:
      :spaces: 2
    :vertical_whitespace:
      :trailing_newlines: 0
    """
    When I run `tailor --config testfile.yml <File>`
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
