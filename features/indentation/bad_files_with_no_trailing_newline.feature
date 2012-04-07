@indentation
Feature: Indentation check on bad fails without trailing newlines

  Background:
    Given my configuration file ".tailor" looks like:
    """
    Tailor.config do |config|
      config.file_set do
        trailing_newlines 0
      end
    end
    """

  @bad_files
  Scenario Outline: Detect singular problems on poorly indented files
    Given <File> exists without a newline at the end
    When I run `tailor -d -c .tailor <File>`
    Then the output should match /Total Problems.*1/
    And the output should match /position:  <Position>/
    And the exit status should be 1

  @multi_line
  Scenarios: 1 problem with classes
    | File                                           | Position |
    | indent/1/class_indented_end                    | 2:1      |
    | indent/1/class_method_def_using_self_outdented | 2:1      |


  @multi_line
  Scenarios: 1 problem with single-line statement
    | File                                                     | Position |
    | indent/1/class_indented_singlestatement                  | 2:3      |
    | indent/1/class_indented_singlestatement_trailing_comment | 2:3      |
    | indent/1/class_outdented_singlestatement                 | 2:1      |
    | indent/1/class_def_outdented_content                     | 3:3      |

  @multi_line
  Scenarios: 1 problem with def
    | File                                     | Position |
    | indent/1/def_indented_end                | 2:1      |
    | indent/1/def_content_indented_end        | 3:1      |
    | indent/1/class_def_content_outdented_end | 4:1      |

  @multi_line
  Scenarios: 1 problem with case
    | File                                                | Position |
    | indent/1/case_indented_whens_level                  | 2:3      |
    | indent/1/case_indented_whens_level_trailing_comment | 2:3      |
    | indent/1/case_outdented_whens_level                 | 2:1      |
    | indent/1/case_when_indented_whens_level             | 3:3      |
    | indent/1/case_when_outdented_whens_level            | 3:1      |
    | indent/1/case_indented_whens_in                     | 2:3      |

  @multi_line
  Scenarios: 1 problem with 'do' loop
    | File                                         | Position |
    | indent/1/while_do_indented                   | 1:1      |
    | indent/1/while_do_indented2                  | 4:1      |
    | indent/1/while_do_indented2_trailing_comment | 4:1      |
    | indent/1/while_do_outdented                  | 2:1      |
    | indent/1/while_do_content_indented           | 3:5      |
    | indent/1/while_do_content_outdented          | 3:3      |
    | indent/1/until_do_indented                   | 4:1      |
    | indent/1/for_do_indented                     | 1:1      |
    | indent/1/loop_do_indented                    | 1:1      |

  @multi_line
  Scenarios: 1 problem with multi-line string
    | File                                                            | Position |
    | indent/1/multi_line_string_first_line_indented                  | 2:3      |
    | indent/1/multi_line_string_first_line_indented_trailing_comment | 2:3      |

  @multi_line
  Scenarios: 1 problem with multi-line operator use
    | File                                                           | Position |
    | indent/1/multi_line_andop_first_line_indented                  | 2:3      |
    | indent/1/multi_line_andop_first_line_indented_trailing_comment | 2:3      |
    | indent/1/multi_line_andop_second_line_indented                 | 3:5      |
    | indent/1/multi_line_string_concat_with_plus_out                | 2:1      |

  @multi_line
  Scenarios: 1 problem with multi-line method ending with period
    | File                                                                            | Position |
    | indent/1/multi_line_method_call_end_in                                          | 5:3      |
    | indent/1/multi_line_method_call_ends_with_period_2nd_line_in                    | 4:5      |
    | indent/1/multi_line_method_call_ends_with_many_periods_last_in                  | 3:4      |
    | indent/1/multi_line_method_call_ends_with_many_periods_last_in_trailing_comment | 3:4      |



