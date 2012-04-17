NAMING_OK = {}
NAMING_1 = {}

NAMING_OK[:single_word_method] =
  %Q{def thing
end}

NAMING_OK[:two_word_method] =
  %Q{def thing_one
end}

NAMING_1[:one_caps_camel_case_method] =
  %Q{def thingOne
end}

NAMING_1[:one_caps_camel_case_method_trailing_comment] =
  %Q{def thingOne   # comment
end}

#-------------------------------------------------------------------------------
NAMING_OK[:single_word_class] =
  %Q{class Thing
end}

NAMING_OK[:single_word_module] =
  %Q{module Thing
end}

NAMING_OK[:two_word_class] =
  %Q{class ThingOne
end}

NAMING_OK[:two_word_module] =
  %Q{module ThingOne
end}

NAMING_1[:one_screaming_snake_case_class] =
  %Q{class Thing_One
end}

NAMING_1[:one_screaming_snake_module_class] =
  %Q{module Thing_One
end}

NAMING_1[:two_screaming_snake_case_class] =
  %Q{class Thing_One_Again
end}

NAMING_1[:two_screaming_snake_module_class] =
  %Q{module Thing_One_Again
end}
