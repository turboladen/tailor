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

