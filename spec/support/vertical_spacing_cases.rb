V_SPACING_OK = {}
V_SPACING_1 = {}

#-------------------------------------------------------------------------------
# Class length
#-------------------------------------------------------------------------------
V_SPACING_OK[:class_five_code_lines] =
  %Q{class Party
  include Clowns

  def barrel_roll
  end
end}

V_SPACING_OK[:embedded_class_five_code_lines] =
  %Q{class Party
  class Pizza
    include Cheese
  end
end}

V_SPACING_1[:class_too_long] =
  %Q{class Party
  include Clowns
  include Pizza

  def barrel_roll
    puts "DOABARRELROLL!"
  end
end}

V_SPACING_1[:parent_class_too_long] =
  %Q{class Party

  class Pizza
    include Cheese
    include Yumminess
  end
end}

#-------------------------------------------------------------------------------
# Method length
#-------------------------------------------------------------------------------
V_SPACING_OK[:method_3_code_lines] =
  %Q{def thing


  puts 'hi'
end}

V_SPACING_OK[:embedded_method_3_code_lines] =
  %Q{def outter_thing
  def thing; puts 'hi'; end


end}

V_SPACING_1[:method_too_long] =
  %Q{def thing
  puts
  puts
end}

V_SPACING_1[:parent_method_too_long] =
  %Q{def thing
  puts
  def inner_thing; print '1'; end
  puts
end}
