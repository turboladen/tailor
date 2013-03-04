H_SPACING_OK = {}

H_SPACING_OK['short_line_no_newline'] = '#' * 79
H_SPACING_OK['short_line_newline_at_81'] =
  %Q{'#{'#' * 78}'
}

=begin
H_SPACING_OK['line_split_by_backslash'] =
  %Q{execute 'myscript' do
  command \\
    '/some/really/long/path/that/would/be/over/eight/chars.sh'
  only_if { something }
end}
=end

#-------------------------------------------------------------------------------
# Comma spacing
#-------------------------------------------------------------------------------
H_SPACING_OK['space_after_comma_in_array'] = %Q{[1, 2]}

H_SPACING_OK['trailing_comma'] = %Q{def thing(one, two,
  three)
end}

H_SPACING_OK['trailing_comma_with_trailing_comment'] =
  %Q{def thing(one, two,  # Comment!
  three)
end}

H_SPACING_OK['no_before_comma_in_array'] = %Q{[1, 2]}
H_SPACING_OK['line_ends_with_backslash'] =
  %Q{{ :thing => a_thing,\\
  :thing2 => another_thing }}

#-------------------------------------------------------------------------------
# Braces
#-------------------------------------------------------------------------------
H_SPACING_OK['empty_hash'] = %Q{{}}
H_SPACING_OK['single_line_hash'] = %Q{{ :one => 'one' }}
H_SPACING_OK['single_line_hash_lonely_braces'] = %Q{{
  :one => 'one'
}}

H_SPACING_OK['hash_as_param_in_parens'] =
  %Q{add_headers({ content_length: new_body.length })}

H_SPACING_OK['two_line_hash'] = %Q{{ :one =>
  'one' }}

H_SPACING_OK['two_line_hash_trailing_comment'] = %Q{{ :one =>    # comment
  'one' }}

H_SPACING_OK['three_line_hash'] = %Q{{ :one =>
  'one', :two =>
  'two' }}

H_SPACING_OK['single_line_block'] = %Q{1..10.times { |n| puts number }}
H_SPACING_OK['multi_line_braces_block'] = %Q{1..10.times { |n|
  puts number }}

H_SPACING_OK['multi_line_qword_using_braces'] = %Q{%w{
  foo
  bar
  baz
}.each do |whatevs|
  bla
end}

H_SPACING_OK['empty_hash_in_multi_line_statement'] =
  %Q{if true
  {}
end}

H_SPACING_OK['multi_line_hash_in_multi_line_statement'] =
  %Q{if true
  options = {
    one: 1
  }
end}

H_SPACING_OK['single_line_string_interp'] = %Q{`\#{IFCONFIG} | grep \#{ip}`}
H_SPACING_OK['single_line_block_in_string_interp'] =
  %Q{"I did this \#{1..10.times { |n| n }} times."}

H_SPACING_OK['empty_hash_in_string_in_block'] =
  %Q{[1].map { |n| { :first => "\#{n}-\#{{}}" } }}

H_SPACING_OK['string_interp_with_colonop'] =
  %Q{"\#{::Rails.root}"}



#-------------------------------------------------------------------------------
# Brackets
#-------------------------------------------------------------------------------
H_SPACING_OK['empty_array'] = %Q{[]}
H_SPACING_OK['simple_array'] = %Q{[1, 2, 3]}
H_SPACING_OK['two_d_array'] = %Q{[[1, 2, 3], ['a', 'b', 'c']]}
H_SPACING_OK['hash_key_reference'] = %Q{thing[:one]}
H_SPACING_OK['array_of_symbols'] =
  %Q{transition [:active, :reactivated] => :opened}
H_SPACING_OK['array_of_hashes'] =
  %Q{[ { :one => [[1, 2, 3], ['a', 'b', 'c']] },
  { :two => [[4, 5, 6], ['d', 'e', 'f']] }]}

H_SPACING_OK['simple_array_lonely_brackets'] =
  %Q{[
  1, 2,
  3
]}

H_SPACING_OK['simple_nested_array_lonely_brackets'] =
  %Q{def thing
  [
    1, 2,
    3
  ]
end}


H_SPACING_OK['empty_array_in_multi_line_statement'] =
  %Q{if true
  []
end}

#-------------------------------------------------------------------------------
# Parens
#-------------------------------------------------------------------------------
H_SPACING_OK['empty_parens'] = %Q{def thing(); end}
H_SPACING_OK['simple_method_call'] = %Q{thing(one, two)}
H_SPACING_OK['multi_line_method_call'] = %Q{thing(one,
  two)}
H_SPACING_OK['multi_line_method_call_lonely_parens'] = %Q{thing(
  one, two
)}
