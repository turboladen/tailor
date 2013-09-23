ARG_INDENT = {}

ARG_INDENT['def_no_arguments'] =
  %q{def foo
  true
end}

ARG_INDENT['def_arguments_fit_on_one_line'] =
  %q{def foo(foo, bar, baz)
  true
end}

ARG_INDENT['def_arguments_aligned'] =
  %q{def something(waka, baka, bing,
              bla, goop, foop)
  stuff
end
}

ARG_INDENT['def_arguments_indented'] =
  %q{def something(waka, baka, bing,
  bla, goop, foop)
  stuff
end
}

ARG_INDENT['call_no_arguments'] =
  %q{bla = method()}

ARG_INDENT['call_arguments_fit_on_one_line'] =
  %q{bla = method(foo, bar, baz, bing, ding)}

ARG_INDENT['call_arguments_aligned'] =
  %q{bla = Something::SomethingElse::SomeClass.method(foo, bar, baz,
                                                 bing, ding)
}

ARG_INDENT['call_arguments_aligned_args_are_integer_literals'] =
  %q{bla = Something::SomethingElse::SomeClass.method(1, 2, 3,
                                                 4, 5)
}

ARG_INDENT['call_arguments_aligned_args_are_string_literals'] =
  %q{bla = Something::SomethingElse::SomeClass.method('foo', 'bar', 'baz',
                                                 'bing', 'ding')
}

ARG_INDENT['call_arguments_aligned_args_have_parens'] =
  %q{bla = Something::SomethingElse::SomeClass.method(foo, bar(), baz,
                                                 bing, ding)
}

ARG_INDENT['call_arguments_aligned_no_parens'] =
  %q{bla = Something::SomethingElse::SomeClass.method foo, bar, baz,
                                                 bing, ding
}

ARG_INDENT['call_arguments_aligned_multiple_lines'] =
  %q{bla = Something::SomethingElse::SomeClass.method(foo, bar, baz,
                                                 bing, ding,
                                                 ginb, gind)
}

ARG_INDENT['call_arguments_indented'] =
  %q{bla = Something::SomethingElse::SomeClass.method(foo, bar, baz,
  bing, ding)
}

ARG_INDENT['call_arguments_indented_separate_line'] =
  %q{bla = Something::SomethingElse::SomeClass.method(
  foo, bar, baz,
  bing, ding
)}

ARG_INDENT['call_arguments_on_next_line'] =
  %q{some_long_method_that_goes_out_to_the_end_of_the_line(
  foo, bar)
}

ARG_INDENT['call_arguments_on_next_line_nested'] =
  %q{if some_long_method_that_goes_out_to_the_end_of_the_line(
    foo, bar)
  my_nested_expression
end}

ARG_INDENT['call_arguments_on_next_line_multiple'] =
  %q{some_long_method_that_goes_out_to_the_end_of_the_line(
  foo, bar)

if diff_long_method_that_goes_out_to_the_end_of_the_line(
    foo, bar)
  my_nested_expression
end}
