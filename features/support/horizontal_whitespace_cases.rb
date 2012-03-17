H_SPACING_1 = {}
H_SPACING_2 = {}

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
