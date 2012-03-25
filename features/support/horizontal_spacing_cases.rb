H_SPACING_OK = {}
H_SPACING_1 = {}
H_SPACING_2 = {}

H_SPACING_OK[:short_line_no_newline] =
  %Q{'#{'#' * 78}'}

H_SPACING_OK[:short_line_newline_at_81] =
  %Q{'#{'#' * 78}'
}

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
H_SPACING_1[:long_line_no_newline] =
  %Q{'#{'#' * 79}'}

H_SPACING_1[:long_line_newline_at_82] =
  %Q{'#{'#' * 79}'
}

#-------------------------------------------------------------------------------
H_SPACING_1[:empty_line_with_spaces] =
  %Q{  }

H_SPACING_1[:empty_line_with_spaces_in_method] =
  %Q{def thing
  
  puts 'something'
end}

H_SPACING_1[:trailing_spaces_on_def] =
  %Q{def thing 
  puts 'something'
end}

#-------------------------------------------------------------------------------
H_SPACING_1[:no_space_after_comma] =
  %Q{[1,2]}

H_SPACING_1[:two_spaces_after_comma] =
  %Q{[1,  2]}

H_SPACING_2[:two_spaces_after_comma_twice] =
  %Q{[1,  2,  3]}

H_SPACING_OK[:space_after_comma_in_array] =
  %Q{[1, 2]}

#-------------------------------------------------------------------------------
H_SPACING_1[:one_space_before_comma] =
  %Q{[1 ,2]}

H_SPACING_1[:two_spaces_before_comma] =
  %Q{[1  , 2]}

H_SPACING_2[:two_spaces_before_comma_twice] =
  %Q{[1  , 2  , 3]}

H_SPACING_OK[:no_before_comma_in_array] =
  %Q{[1, 2]}


