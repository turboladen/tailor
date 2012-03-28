V_SPACING_OK = {}
V_SPACING_1 = {}

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

