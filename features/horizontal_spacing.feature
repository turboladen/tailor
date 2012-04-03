Feature: Horizontal spacing detection
  As a Ruby developer, I want to be able to detect horizontal spacing
  problems so that I can fix them.

  Background:
    Given my configuration file ".tailor" looks like:
    """
    Tailor.config do |config|
      config.file_set do
        trailing_newlines 0
      end
    end
    """

  @bad_files @hard_tabs

  Scenario Outline: Detect hard tabs
    Given <File> exists without a newline at the end
    When I run `tailor -d -c .tailor <File>`
    Then the output should match /Total Problems.*<Count>/
    And the output should match /position:  <Position>/
    And the output should match /position:  <Position 2>/
    And the exit status should be 1

  Scenarios: Hard tab
    | File                                        | Position | Position 2 | Count |
    | h_spacing/1/hard_tab                        | 2:0      |            | 1     |
    | h_spacing/1/hard_tab_with_spaces            | 3:0      |            | 1     |
    | h_spacing/1/hard_tab_with_1_indented_space  | 3:0      |            | 1     |
    | h_spacing/2/hard_tab_with_2_indented_spaces | 3:0      | 3:5        | 2     |

  @bad_files @long_lines

  Scenario Outline: Detect long lines
    Given <File> exists without a newline at the end
    When I run `tailor -d -c .tailor <File>`
    Then the output should match /Total Problems.*<Count>/
    And the output should match /position:  <Position>/
    And the exit status should be 1

  Scenarios:
    | File                                | Position | Count |
    | h_spacing/1/long_line_no_newline    | 1:81     | 1     |
    | h_spacing/1/long_line_newline_at_82 | 1:81     | 1     |

  @good_files @long_lines

  Scenario Outline: Lines under long-line threshold
    Given <File> exists without a newline at the end
    When I run `tailor -d -c .tailor <File>`
    Then the output should match /Total Problems.*0/
    And the exit status should be 0

  Scenarios:
    | File                                  |
    | h_spacing/ok/short_line_no_newline    |
    | h_spacing/ok/short_line_newline_at_81 |

  @bad_files @trailing_spaces

  Scenario Outline: Lines with trailing spaces
    Given <File> exists without a newline at the end
    When I run `tailor -d -c .tailor <File>`
    Then the output should match /Total Problems.*<Count>/
    And the output should match /position:  <Position>/
    And the exit status should be 1

  Scenarios:
    | File                                         | Count | Position |
    | h_spacing/1/empty_line_with_spaces           | 1     | 1:2      |
    | h_spacing/1/empty_line_with_spaces_in_method | 1     | 2:2      |
    | h_spacing/1/trailing_spaces_on_def           | 1     | 1:10     |

  @bad_files @commas

  Scenario Outline: Lines with bad comma spacing
    Given <File> exists without a newline at the end
    When I run `tailor -d -c .tailor <File>`
    Then the output should match /Total Problems.*<Count>/
    And the output should match /position:  <Position>/
    And the output should match /position:  <Position 2>/
    And the exit status should be 1

  Scenarios:
    | File                                             | Count | Position | Position 2 |
    | h_spacing/1/no_space_after_comma                 | 1     | 1:3      |            |
    | h_spacing/1/two_spaces_after_comma               | 1     | 1:3      |            |
    | h_spacing/2/two_spaces_after_comma_twice         | 2     | 1:3      | 1:7        |
    | h_spacing/1/one_space_before_comma               | 1     | 1:4      |            |
    | h_spacing/1/two_spaces_before_comma              | 1     | 1:3      |            |
    | h_spacing/2/two_spaces_before_comma_twice        | 2     | 1:3      | 1:8        |
    | h_spacing/2/spaces_before_with_trailing_comments | 2     | 2:3      | 3:3        |

  @good_files @commas

  Scenario Outline: Lines with good comma spacing
    Given <File> exists without a newline at the end
    When I run `tailor -d -c .tailor <File>`
    Then the output should match /Total Problems.*0/
    And the exit status should be 0

  Scenarios:
    | File                                              |
    | h_spacing/ok/space_after_comma_in_array           |
    | h_spacing/ok/trailing_comma                       |
    | h_spacing/ok/trailing_comma_with_trailing_comment |

  @good_files @braces

  Scenario Outline: Lines with good spacing around braces
    Given <File> exists without a newline at the end
    When I run `tailor -d -c .tailor <File>`
    Then the output should match /Total Problems.*0/
    And the exit status should be 0

  @single_line
  Scenarios: Single-line
    | File                                            |
    | h_spacing/ok/empty_hash                         |
    | h_spacing/ok/single_line_hash                   |
    | h_spacing/ok/single_line_hash_lonely_braces     |
    | h_spacing/ok/single_line_block                  |
    | h_spacing/ok/single_line_string_interp          |
    | h_spacing/ok/single_line_block_in_string_interp |
    | h_spacing/ok/empty_hash_in_string_in_block      |
    | h_spacing/ok/string_interp_with_colonop         |
    | h_spacing/ok/hash_as_param_in_parens            |

  @multi_line
  Scenarios: Multi-line
    | File                                                 |
    | h_spacing/ok/two_line_hash                           |
    | h_spacing/ok/two_line_hash_trailing_comment          |
    | h_spacing/ok/three_line_hash                         |
    | h_spacing/ok/multi_line_braces_block                 |
    | h_spacing/ok/multi_line_qword_using_braces           |
    | h_spacing/ok/empty_hash_in_multi_line_statement      |
    | h_spacing/ok/multi_line_hash_in_multi_line_statement |

  @bad_files @braces

  Scenario Outline: Lines with bad spacing around braces
    Given <File> exists without a newline at the end
    When I run `tailor -d -c .tailor <File>`
    Then the output should match /Total Problems.*<Problems>/
    And the output should match /position:  <Position>/
    And the output should match /position:  <Position 2>/
    And the exit status should be 1

  @single_line
  Scenarios: Single-line
    | File                                                                  | Position | Position 2 | Problems |
    | h_spacing/1/single_line_hash_2_spaces_before_lbrace                   | 1:9      |            | 1        |
    | h_spacing/1/single_line_hash_2_spaces_before_rbrace                   | 1:25     |            | 1        |
    | h_spacing/1/single_line_hash_2_spaces_after_lbrace                    | 1:9      |            | 1        |
    | h_spacing/1/single_line_hash_0_spaces_before_lbrace                   | 1:7      |            | 1        |
    | h_spacing/1/single_line_block_2_spaces_before_lbrace                  | 1:13     |            | 1        |
    | h_spacing/1/single_line_block_in_string_interp_2_spaces_before_lbrace | 1:27     |            | 1        |
    | h_spacing/1/single_line_block_0_spaces_before_lbrace                  | 1:11     |            | 1        |
    | h_spacing/1/space_in_empty_hash_in_string_in_block                    | 1:36     |            | 1        |
    | h_spacing/2/no_space_after_l_before_r_after_string_interp             | 1:69     | 1:86       | 2        |
    | h_spacing/2/no_space_before_consecutive_rbraces                       | 1:72     | 1:73       | 2        |

  @multi_line
  Scenarios: Multi-line
    | File                                                                      | Position | Position 2 | Problems |
    | h_spacing/1/two_line_hash_2_spaces_before_lbrace                          | 2:12     |            | 1        |
    | h_spacing/1/two_line_hash_2_spaces_before_rbrace                          | 2:28     |            | 1        |
    | h_spacing/1/two_line_hash_2_spaces_before_lbrace_lonely_braces            | 2:12     |            | 1        |
    | h_spacing/1/two_line_braces_block_2_spaces_before_lbrace                  | 1:13     |            | 1        |
    | h_spacing/1/two_line_braces_block_0_spaces_before_lbrace_trailing_comment | 1:11     |            | 1        |

  @good_files @brackets

  Scenario Outline: Lines with good spacing around brackets
    Given <File> exists without a newline at the end
    When I run `tailor -d -c .tailor <File>`
    Then the output should match /Total Problems.*0/
    And the exit status should be 0

  @single_line
  Scenarios: Single-line
    | File                            |
    | h_spacing/ok/empty_array        |
    | h_spacing/ok/simple_array       |
    | h_spacing/ok/two_d_array        |
    | h_spacing/ok/hash_key_reference |
    | h_spacing/ok/array_of_hashes    |
    | h_spacing/ok/array_of_symbols   |

  @multi_line
  Scenarios: Multi-line
    | File                                             |
    | h_spacing/ok/simple_array_lonely_brackets        |
    | h_spacing/ok/simple_nested_array_lonely_brackets |
    | h_spacing/ok/empty_array_in_multi_line_statement |

  @bad_files @brackets

  Scenario Outline: Lines with bad spacing around brackets
    Given <File> exists without a newline at the end
    When I run `tailor -d -c .tailor <File>`
    Then the output should match /Total Problems.*<Problems>/
    And the output should match /position:  <Position>/
    And the output should match /position:  <Position 2>/
    And the exit status should be 1

  @single_line
  Scenarios: Single-line
    | File                                           | Position | Position 2 | Problems |
    | h_spacing/1/space_in_empty_array               | 1:1      |            | 1        |
    | h_spacing/1/simple_array_space_after_lbracket  | 1:1      |            | 1        |
    | h_spacing/1/simple_array_space_before_rbracket | 1:9      |            | 1        |
    | h_spacing/1/hash_key_ref_space_before_rbracket | 1:11     |            | 1        |
    | h_spacing/1/hash_key_ref_space_after_lbracket  | 1:6      |            | 1        |
    | h_spacing/2/two_d_array_space_after_lbrackets  | 1:1      | 1:14       | 2        |
    | h_spacing/2/two_d_array_space_before_rbrackets | 1:10     | 1:30       | 2        |

  @good_files @parens

  Scenario Outline: Lines with good spacing around parens
    Given <File> exists without a newline at the end
    When I run `tailor -d -c .tailor <File>`
    Then the output should match /Total Problems.*0/
    And the exit status should be 0

  @single_line
  Scenarios: Single-line
    | File                            |
    | h_spacing/ok/empty_parens       |
    | h_spacing/ok/simple_method_call |

  @multi_line
  Scenarios: Multi-line
    | File                                              |
    | h_spacing/ok/multi_line_method_call               |
    | h_spacing/ok/multi_line_method_call_lonely_parens |

  @bad_files @parens

  Scenario Outline: Lines with bad spacing around parens
    Given <File> exists without a newline at the end
    When I run `tailor -d -c .tailor <File>`
    Then the output should match /Total Problems.*<Problems>/
    And the output should match /position:  <Position>/
    And the output should match /position:  <Position 2>/
    And the exit status should be 1

  @single_line
  Scenarios: Single-line
    | File                                                                      | Position | Position 2 | Problems |
    | h_spacing/1/simple_method_call_space_after_lparen                         | 1:6      |            | 1        |
    | h_spacing/1/simple_method_call_space_before_rparen                        | 1:15     |            | 1        |
    | h_spacing/1/method_call_space_after_lparen_trailing_comment               | 1:6      |            | 1        |
    | h_spacing/2/method_call_space_after_lparen_before_rparen_trailing_comment | 1:6      | 1:16       | 2        |

  @multi_line
  Scenarios: Multi-line
    | File                                                                   | Position | Position 2 | Problems |
    | h_spacing/1/multi_line_method_call_space_after_lparen                  | 1:6      |            | 1        |
    | h_spacing/1/multi_line_method_call_space_after_lparen_trailing_comment | 1:6      |            | 1        |

