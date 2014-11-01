QUOTING = {}

QUOTING['single_quotes_no_interpolation'] =
  %q(foo = 'bar'
)

QUOTING['double_quotes_with_interpolation'] =
  %q(foo = "bar#{baz}"
)

QUOTING['double_quotes_no_interpolation'] =
  %q(foo = "bar"
)

QUOTING['double_quotes_no_interpolation_twice'] =
  %q(foo = "bar" + "baz"
)

QUOTING['escape_sequence'] =
  %q(foo = "bar\n"
)

QUOTING['nested_quotes'] =
  %q(foo = "foo#{bar('baz')}"
)
