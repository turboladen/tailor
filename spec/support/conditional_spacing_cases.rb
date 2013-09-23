CONDITIONAL_SPACING = {}

CONDITIONAL_SPACING['no_space_after_if'] =
  %q{if(foo)
end}

CONDITIONAL_SPACING['space_after_if'] =
  %q{if (foo)
end}

CONDITIONAL_SPACING['no_parens'] =
  %q{if foo
end}

CONDITIONAL_SPACING['nested_parens'] =
  %q{if(foo(bar))
end}

CONDITIONAL_SPACING['no_space_after_unless'] =
  %q{unless(foo)
end}

CONDITIONAL_SPACING['space_after_unless'] =
  %q{unless (foo)
end}

CONDITIONAL_SPACING['no_space_after_case'] =
  %q{puts case(true)
when true then 'a'
when false then 'b'
end}

CONDITIONAL_SPACING['space_after_case'] =
  %q{puts case (true)
when true then 'a'
when false then 'b'
end}
