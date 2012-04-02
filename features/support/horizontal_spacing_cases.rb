H_SPACING_OK = {}
H_SPACING_1 = {}
H_SPACING_2 = {}

H_SPACING_OK[:short_line_no_newline] = %Q{'#{'#' * 78}'}
H_SPACING_OK[:short_line_newline_at_81] =
  %Q{'#{'#' * 78}'
}

#-------------------------------------------------------------------------------
# Hard tabs
#-------------------------------------------------------------------------------
H_SPACING_1[:hard_tab] =
  %Q{def something
\tputs "something"
end}

H_SPACING_1[:hard_tab_with_spaces] =
  %Q{class Thing
  def something
\t  puts "something"
  end
end}

# This only reports the hard tab problem (and not the indentation problem)
# because a hard tab is counted as 1 space; here, this is 4 spaces, so it
# looks correct to the parser.  I'm leaving this behavior, as detecting the
# hard tab should signal the problem.  If you fix the hard tab and don't
# fix indentation, tailor will flag you on the indentation on the next run.
H_SPACING_1[:hard_tab_with_1_indented_space] =
  %Q{class Thing
  def something
\t   puts "something"
  end
end}

H_SPACING_2[:hard_tab_with_2_indented_spaces] =
  %Q{class Thing
  def something
\t    puts "something"
  end
end}

#-------------------------------------------------------------------------------
# Long lines
#-------------------------------------------------------------------------------
H_SPACING_1[:long_line_no_newline] = %Q{'#{'#' * 79}'}
H_SPACING_1[:long_line_newline_at_82] =%Q{'#{'#' * 79}'
}

#-------------------------------------------------------------------------------
# Trailing whitespace
#-------------------------------------------------------------------------------
H_SPACING_1[:empty_line_with_spaces] = %Q{  }
H_SPACING_1[:empty_line_with_spaces_in_method] = %Q{def thing
  
  puts 'something'
end}

H_SPACING_1[:trailing_spaces_on_def] = %Q{def thing 
  puts 'something'
end}

#-------------------------------------------------------------------------------
# Comma spacing
#-------------------------------------------------------------------------------
H_SPACING_1[:no_space_after_comma] = %Q{[1,2]}
H_SPACING_1[:two_spaces_after_comma] = %Q{[1,  2]}
H_SPACING_1[:one_space_before_comma] = %Q{[1 ,2]}
H_SPACING_1[:two_spaces_before_comma] = %Q{[1  , 2]}
H_SPACING_2[:two_spaces_before_comma_twice] = %Q{[1  , 2  , 3]}
H_SPACING_2[:two_spaces_after_comma_twice] = %Q{[1,  2,  3]}

H_SPACING_2[:spaces_before_with_trailing_comments] = %Q{[
  1 ,   # Comment!
  2 ,   # Another comment.
}

H_SPACING_OK[:space_after_comma_in_array] = %Q{[1, 2]}

H_SPACING_OK[:trailing_comma] = %Q{def thing(one, two,
  three)
end}

H_SPACING_OK[:trailing_comma_with_trailing_comment] =
  %Q{def thing(one, two,  # Comment!
  three)
end}

H_SPACING_OK[:no_before_comma_in_array] = %Q{[1, 2]}

#-------------------------------------------------------------------------------
# Braces
#-------------------------------------------------------------------------------
H_SPACING_OK[:empty_hash] = %Q{{}}
H_SPACING_OK[:single_line_hash] = %Q{{ :one => 'one' }}
H_SPACING_OK[:single_line_hash_lonely_braces] = %Q{{
  :one => 'one'
}}

H_SPACING_OK[:hash_as_param_in_parens] =
  %Q{add_headers({ content_length: new_body.length })}

H_SPACING_OK[:two_line_hash] = %Q{{ :one =>
'one' }}

H_SPACING_OK[:two_line_hash_trailing_comment] = %Q{{ :one =>    # comment
'one' }}

H_SPACING_OK[:three_line_hash] = %Q{{ :one =>
'one', :two =>
'two' }}

H_SPACING_OK[:single_line_block] = %Q{1..10.times { |n| puts number }}
H_SPACING_OK[:multi_line_braces_block] = %Q{1..10.times { |n|
puts number }}

H_SPACING_OK[:multi_line_qword_using_braces] = %Q{%w{
  foo
  bar
  baz
}.each do |whatevs|
  bla
end}

H_SPACING_OK[:empty_hash_in_multi_line_statement] =
  %Q{if true
  {}
end}

H_SPACING_OK[:multi_line_hash_in_multi_line_statement] =
  %Q{if true
  options = {
    one: 1
  }
end}

H_SPACING_OK[:single_line_string_interp] = %Q{`\#{IFCONFIG} | grep \#{ip}`}
H_SPACING_OK[:single_line_block_in_string_interp] =
  %Q{"I did this \#{1..10.times { |n| n }} times."}

H_SPACING_OK[:empty_hash_in_string_in_block] =
  %Q{[1].map { |n| { :first => "\#{n}-\#{{}}" } }}

H_SPACING_OK[:string_interp_with_colonop] =
  %Q{"\#{::Rails.root}"}

H_SPACING_1[:single_line_hash_2_spaces_before_lbrace] =
  %Q{thing =  { :one => 'one' }}

H_SPACING_1[:single_line_hash_2_spaces_before_rbrace] =
  %Q{thing = { :one => 'one'  }}

H_SPACING_1[:single_line_hash_2_spaces_after_lbrace] =
  %Q{thing = {  :one => 'one' }}

H_SPACING_1[:single_line_hash_0_spaces_before_lbrace] =
  %Q{thing ={ :one => 'one' }}

H_SPACING_1[:two_line_hash_2_spaces_before_lbrace] = %Q{thing1 =
  thing2 =  { :one => 'one' }}

H_SPACING_1[:two_line_hash_2_spaces_before_rbrace] = %Q{thing1 =
  thing2 = { :one => 'one'  }}

H_SPACING_1[:two_line_hash_2_spaces_before_lbrace_lonely_braces] =
  %Q{thing1 =
  thing2 =  {
  :one => 'one'
}}

H_SPACING_1[:space_in_empty_hash_in_string_in_block] =
  %Q{[1].map { |n| { :first => "\#{n}-\#{{ }}" } }}

H_SPACING_1[:single_line_block_2_spaces_before_lbrace] =
  %Q{1..10.times  { |n| puts n }}

H_SPACING_1[:single_line_block_in_string_interp_2_spaces_before_lbrace] =
  %Q{"I did this \#{1..10.times  { |n| puts n }} times."}

H_SPACING_1[:single_line_block_0_spaces_before_lbrace] =
  %Q{1..10.times{ |n| puts n }}

H_SPACING_1[:two_line_braces_block_2_spaces_before_lbrace] =
%Q{1..10.times  { |n|
puts n}}

H_SPACING_1[:two_line_braces_block_0_spaces_before_lbrace_trailing_comment] =
  %Q{1..10.times{ |n|    # comment
puts n}}

H_SPACING_2[:no_space_after_l_before_r_after_string_interp] =
  %Q{logger.debug "Upgrading from \#{current_version} to \#{new_version}", {:format => :short}}

H_SPACING_2[:no_space_before_consecutive_rbraces] =
  %Q{thing = { 'id' => "\#{source}", 'attributes' => { 'height' => "\#{height}"}}}

#-------------------------------------------------------------------------------
# Brackets
#-------------------------------------------------------------------------------
H_SPACING_OK[:empty_array] = %Q{[]}
H_SPACING_OK[:simple_array] = %Q{[1, 2, 3]}
H_SPACING_OK[:two_d_array] = %Q{[[1, 2, 3], ['a', 'b', 'c']]}
H_SPACING_OK[:hash_key_reference] = %Q{thing[:one]}
H_SPACING_OK[:array_of_symbols] =
  %Q{transition [:active, :reactivated] => :opened}
H_SPACING_OK[:array_of_hashes] =
  %Q{[ { :one => [[1, 2, 3], ['a', 'b', 'c']] },
  { :two => [[4, 5, 6], ['d', 'e', 'f']] }]}

H_SPACING_OK[:simple_array_lonely_brackets] =
  %Q{[
  1, 2,
  3
]}

H_SPACING_OK[:simple_nested_array_lonely_brackets] =
  %Q{def thing
  [
    1, 2,
    3
  ]
end}


H_SPACING_OK[:empty_array_in_multi_line_statement] =
  %Q{if true
  []
end}

H_SPACING_1[:space_in_empty_array] = %Q{[ ]}
H_SPACING_1[:simple_array_space_after_lbracket] = %Q{[ 1, 2, 3]}
H_SPACING_1[:simple_array_space_before_rbracket] = %Q{[1, 2, 3 ]}
H_SPACING_1[:hash_key_ref_space_before_rbracket] = %Q{thing[:one ]}
H_SPACING_1[:hash_key_ref_space_after_rbracket] = %Q{thing[ :one]}
H_SPACING_2[:two_d_array_space_after_lbrackets] =
  %Q{[ [1, 2, 3], [ 'a', 'b', 'c']]}
H_SPACING_2[:two_d_array_space_before_rbrackets] =
  %Q{[[1, 2, 3 ], [ 'a', 'b', 'c'] ]}

#-------------------------------------------------------------------------------
# Parens
#-------------------------------------------------------------------------------
H_SPACING_OK[:empty_parens] = %Q{def thing()}
H_SPACING_OK[:simple_method_call] = %Q{thing(one, two)}
H_SPACING_OK[:multi_line_method_call] = %Q{thing(one,
  two)}
H_SPACING_OK[:multi_line_method_call_lonely_parens] = %Q{thing(
  one, two
)}

H_SPACING_1[:simple_method_call_space_after_lparen] = %Q{thing( one, two)}
H_SPACING_1[:simple_method_call_space_before_rparen] = %Q{thing(one, two )}
H_SPACING_1[:method_call_space_after_lparen_trailing_comment] =
  %Q{thing( one, two)    # comment}
H_SPACING_2[:method_call_space_after_lparen_before_rparen_trailing_comment] =
  %Q{thing( one, two )    # comment}

H_SPACING_1[:multi_line_method_call_space_after_lparen] = %Q{thing( one,
  two)}
H_SPACING_1[:multi_line_method_call_space_after_lparen_trailing_comment] =
  %Q{thing( one,
  two)}


