cloth :vertical_whitespace do
  any_class.must_have(2, :blank_lines, :before) if preceded_by(:any_code)
  stitch { classes.must_have(2, :blank_lines, :before) if preceded_by :any_code }
  any_class.must_have(2, :blank_lines, :after) if followed_by(any_code)
  any_method.must_have(1, :blank_line, :before) unless preceded_by(a_full_line_comment)
  any_method.must_have(1, :blank_line, :after)
  #any_return_statement.must_have(1, :blank_line, :before) unless the_method.line_count == 1
  any_return_statement.must_have(1, :blank_line, :before) unless the_method.is(1).line
  any_comment.must_have(1, :blank_line, :before) unless preceded_by(outdented_code)
  any_multiline_block.must_have(1, :blank_line, :before) unless preceded_by(outdented_code, a_full_line_comment)
  any_multiline_conditional.must_have(1, :blank_line, :before) unless preceded_by(outdented_code, a_full_line_comment)
  any_multiline_loop.must_have(1, :blank_line, :before) unless preceded_by(outdented_code, a_full_line_comment)
end

cloth :horizontal_whitespace do
  a_comma.must_be preceded_by(0, :spaces)
  the_characters(",", ";").must_be followed_by(1, :space)
  a_multiline_method.must_be indented_by(2, :spaces)
  a_multiline_method.must_not_have(:any, :hard_tabs)
  the_operator("=").must_be surrounded_by(1, :space) unless used_in(method_parameters)
end

cloth :code_line do
  length.must_be <= 120
end

garment :rails do
  stitch :vertical_whitespace
  stitch :horizontal_whitespace
  stitch :code_line
end

