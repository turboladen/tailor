NAMING_OK = {}

NAMING_OK['single_word_method'] =
  %(def thing
end)

NAMING_OK['two_word_method'] =
  %(def thing_one
end)

#-------------------------------------------------------------------------------
NAMING_OK['single_word_class'] =
  %(class Thing
end)

NAMING_OK['single_word_module'] =
  %(module Thing
end)

NAMING_OK['two_word_class'] =
  %(class ThingOne
end)

NAMING_OK['two_word_module'] =
  %(module ThingOne
end)
