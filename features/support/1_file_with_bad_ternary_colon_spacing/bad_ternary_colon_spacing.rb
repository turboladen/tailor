# Perfect spacing around ternary colon
bobo = true ? true : false

# No space after ternary colon
bobo = true ? true :false

# No space before ternary colon
bobo = true ? true: false

# No space before or after ternary colon
bobo = true ? true:false

# 2 spaces after ternary colon
bobo = true ? true :  false

# 2 spaces before ternary colon
bobo = true ? true  : false

# Skip when colon is part of a symbol or namespace operator
bobo = { :thing => :clown }
bobo[:thing] == :dog ? bobo[:thing] : Class::String