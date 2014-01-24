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
bobo = { thing: ":clown" }
bobo[:thing] == :dog ? bobo[:thing] : Math::PI

# Skip when colon is part of Regexp class
bobo[:thing].scan(/[:alpha:]/)

# Skip when setting load path
$:.unshift File.dirname(__FILE__)

# Skip when question mark method is followed by a symbol
if bobo[:thing].eql? :clown
end
