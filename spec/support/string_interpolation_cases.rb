INTERPOLATION = {}

INTERPOLATION['one_variable_interpolated_only'] =
  %q(puts "#{bing}"
)

INTERPOLATION['mixed_content_and_expression'] =
  %q(puts "hello: #{bing}"
)

INTERPOLATION['no_string'] =
  %q(puts bing
)

INTERPOLATION['two_variables'] =
  %q(puts "#{bing}#{bar}"
)

INTERPOLATION['two_strings_with_unnecessary_interpolation'] =
  %q(puts "#{foo}" + "#{bar}"
)

INTERPOLATION['multiline_string_with_unnecessary_interpolation'] =
  %q(puts "#{foo +
bar -
baz}"
)

INTERPOLATION['multiline_word_list'] =
  %q(%w{
  foo
  bar
  baz
})

INTERPOLATION['nested_interpolation'] =
  %q(def friendly_time(time)
  if hours < 24
    "#{(hours > 0) ? "#{hours} hour" : '' }#{(hours > 1) ? 's' : ''}" +
      " #{(mins > 0) ? "#{mins} minute" : '' }#{(mins > 1) ? 's' : ''}" +
      " #{seconds} second#{(seconds > 1) ? 's' : ''} ago"
  else
    time.to_s
  end
end)
