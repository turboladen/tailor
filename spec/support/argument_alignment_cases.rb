ARG_INDENT = {}

ARG_INDENT['def_no_arguments'] =
  %(def foo
  true
end)

ARG_INDENT['def_arguments_fit_on_one_line'] =
  %(def foo(foo, bar, baz)
  true
end)

ARG_INDENT['def_arguments_aligned'] =
  %(def something(waka, baka, bing,
              bla, goop, foop)
  stuff
end
)

ARG_INDENT['def_arguments_indented'] =
  %(def something(waka, baka, bing,
  bla, goop, foop)
  stuff
end
)

ARG_INDENT['call_no_arguments'] =
  %(bla = method())

ARG_INDENT['call_arguments_fit_on_one_line'] =
  %(bla = method(foo, bar, baz, bing, ding))

ARG_INDENT['call_arguments_aligned'] =
  %(bla = Something::SomethingElse::SomeClass.method(foo, bar, baz,
                                                 bing, ding)
)

ARG_INDENT['call_arguments_aligned_args_are_integer_literals'] =
  %(bla = Something::SomethingElse::SomeClass.method(1, 2, 3,
                                                 4, 5)
)

ARG_INDENT['call_arguments_aligned_args_are_string_literals'] =
  %(bla = Something::SomethingElse::SomeClass.method('foo', 'bar', 'baz',
                                                 'bing', 'ding')
)

ARG_INDENT['call_arguments_aligned_args_have_parens'] =
  %(bla = Something::SomethingElse::SomeClass.method(foo, bar(), baz,
                                                 bing, ding)
)

ARG_INDENT['call_arguments_aligned_no_parens'] =
  %(bla = Something::SomethingElse::SomeClass.method foo, bar, baz,
                                                 bing, ding
)

ARG_INDENT['call_arguments_aligned_multiple_lines'] =
  %(bla = Something::SomethingElse::SomeClass.method(foo, bar, baz,
                                                 bing, ding,
                                                 ginb, gind)
)

ARG_INDENT['call_arguments_indented'] =
  %(bla = Something::SomethingElse::SomeClass.method(foo, bar, baz,
  bing, ding)
)

ARG_INDENT['call_arguments_indented_separate_line'] =
  %(bla = Something::SomethingElse::SomeClass.method(
  foo, bar, baz,
  bing, ding
))

ARG_INDENT['call_arguments_on_next_line'] =
  %(some_long_method_that_goes_out_to_the_end_of_the_line(
  foo, bar)
)

ARG_INDENT['call_arguments_on_next_line_nested'] =
  %(if some_long_method_that_goes_out_to_the_end_of_the_line(
    foo, bar)
  my_nested_expression
end)

ARG_INDENT['call_arguments_on_next_line_multiple'] =
  %(some_long_method_that_goes_out_to_the_end_of_the_line(
  foo, bar)

if diff_long_method_that_goes_out_to_the_end_of_the_line(
    foo, bar)
  my_nested_expression
end)
