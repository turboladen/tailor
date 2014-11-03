V_SPACING_OK = {}

#-------------------------------------------------------------------------------
# Class length
#-------------------------------------------------------------------------------
V_SPACING_OK['class_five_code_lines'] =
  %(class Party
  include Clowns

  def barrel_roll
  end
end)

V_SPACING_OK['embedded_class_five_code_lines'] =
  %(class Party
  class Pizza
    include Cheese
  end
end)

#-------------------------------------------------------------------------------
# Method length
#-------------------------------------------------------------------------------
V_SPACING_OK['method_3_code_lines'] =
  %(def thing


  puts 'hi'
end)

V_SPACING_OK['embedded_method_3_code_lines'] =
  %(def outter_thing
  def thing; puts 'hi'; end


end)
