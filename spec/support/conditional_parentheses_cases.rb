CONDITIONAL_PARENTHESES = {}

CONDITIONAL_PARENTHESES['no_parentheses'] =
  %q{if foo
end}

CONDITIONAL_PARENTHESES['with_parentheses'] =
  %q{if (foo)
end}

CONDITIONAL_PARENTHESES['with_parentheses_no_space'] =
  %q{if(foo)
end}

CONDITIONAL_PARENTHESES['method_call'] =
  %q{if foo(bar)
end}

CONDITIONAL_PARENTHESES['indented_method_call'] =
%q{foo do
  if foo(bar)
  end
end}

CONDITIONAL_PARENTHESES['method_call_on_parens'] =
  %q{unless (foo & bar).sort
end
}

CONDITIONAL_PARENTHESES['double_parens'] =
  %q{if ((bar))
end}

CONDITIONAL_PARENTHESES['unless_no_parentheses'] =
  %q{unless bar
end}

CONDITIONAL_PARENTHESES['unless_with_parentheses'] =
  %q{unless (bar)
end}

CONDITIONAL_PARENTHESES['case_no_parentheses'] =
  %q{case bar
when 1 then 'a'
when 2 then 'b'
end}

CONDITIONAL_PARENTHESES['case_with_parentheses'] =
  %q{case (bar)
when 1 then 'a'
when 2 then 'b'
end}

CONDITIONAL_PARENTHESES['while_no_parentheses'] =
  %q{while bar
end}

CONDITIONAL_PARENTHESES['while_with_parentheses'] =
  %q{while (bar)
end}
