NAMING_OK = {}

NAMING_OK[:single_word_method] =
  %Q{def thing
end}

NAMING_OK[:two_word_method] =
  %Q{def thing_one
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
