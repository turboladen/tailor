CONDITIONAL_PARENTHESES = {}

CONDITIONAL_PARENTHESES['no_parentheses'] =
  %(if foo
end)

CONDITIONAL_PARENTHESES['with_parentheses'] =
  %(if (foo)
end)

CONDITIONAL_PARENTHESES['with_parentheses_no_space'] =
  %(if(foo)
end)

CONDITIONAL_PARENTHESES['method_call'] =
  %(if foo(bar)
end)

CONDITIONAL_PARENTHESES['indented_method_call'] =
%(foo do
  if foo(bar)
  end
end)

CONDITIONAL_PARENTHESES['method_call_on_parens'] =
  %(unless (foo & bar).sort
end
)

CONDITIONAL_PARENTHESES['double_parens'] =
  %(if ((bar))
end)

CONDITIONAL_PARENTHESES['unless_no_parentheses'] =
  %(unless bar
end)

CONDITIONAL_PARENTHESES['unless_with_parentheses'] =
  %(unless (bar)
end)

CONDITIONAL_PARENTHESES['case_no_parentheses'] =
  %(case bar
when 1 then 'a'
when 2 then 'b'
end)

CONDITIONAL_PARENTHESES['case_with_parentheses'] =
  %(case (bar)
when 1 then 'a'
when 2 then 'b'
end)

CONDITIONAL_PARENTHESES['while_no_parentheses'] =
  %(while bar
end)

CONDITIONAL_PARENTHESES['while_with_parentheses'] =
  %(while (bar)
end)
