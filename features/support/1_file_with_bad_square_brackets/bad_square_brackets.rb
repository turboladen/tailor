# Arrays...
# Perfect
thing = []

# 1 space after [
thing = [ ]

# Perfect with element
thing = [one]

# 1 space after [ with element
thing = [ one]

# 1 space before ] with element
thing = [one ]

# 1 space before and after [ and ]
thing = [ one ]

# Perfect element reference
thing[0]

# 1 space after [ with element reference
thing[ 0]

# 1 space before [ with element reference
thing [0]

# 1 space before ] with element reference
thing[0 ]

# Pefect multi-line
thing = [
  one,
  two
]

# Perfect multi-line, indented
def thing
  a_thing = [
    one,
    two
  ]
end


# Hash references...
thing = { :one => 1 }

# Perfect element reference
thing[:one]

# 1 space after [ with element reference
thing[ :one]

# 1 space before [ with element reference
thing [:one]

# 1 space before ] with element reference
thing[:one ]
