#------------------------
# single-token indenters
#------------------------

=begin
# Operators
1 +
  2

2 -
  1 -
  0 +
  12

# Commas (not used for separating enclosed elements)
def my_thing one,
  two
end

# Periods
Object.
  new

# Modifiers
#puts "hi" if
#  true



# Operators plus period
1 +
  String.
    new("1").to_i +
  3 -
  2


#------------------------
# double-token indenters
#------------------------
=end
# keyword/end statements
class Thing; end
class Thing
end
class Thing
 end

# paren statements
(1)

(
  1)

(1
)

(
  1
)

# bracket statements
[2]
[
  2]
[2
]
[
  2
]

# brace statements
{ three: 3 }

{
  three: 3 }

{ three: 3
}

{
  three: 3
}

# keyword/end + parens
def your_thing(one); end

def your_thing(
  one)

  1
end

#def your_thing(one
#  )
#end

def your_thing(
  one
)
  puts "stuff"
end

# 1. [ has content +next
# 1. { has content +next
# 1. ( no content +next
# 2. ) has content -next
# 3. } no content -next -this
# 4 no content -next -this
# net next: 0
# net this: -2
[{ :one => your_thing(
  1)
}
]

# 1. [ has content +next
# 1. { has content +next
# 1. ( has content +next
# 2. ) no content -next -this
# 3. } no content -next -this
# 3. ] has content -next
# net next: 0
# net this: -2
[{ :one => your_thing(1
  )
}]

=begin
# 1. [ has content +next
# 1. { has content +next
# 1. ( has content +next
# 1. ) has content -next
# 2. } no content -next -this
# 2. ] has content -next
# net next: 0
# net this: -1
[{ :one => your_thing(1)
}]

# 1. [ has content   +next ( 1)   this ( 0)
# 1. { no content    +next ( 1)   this ( 0)
#      line end:      next ( 0)   this ( 0)
# 2. ( has content   +next ( 1)   this ( 0)
# 2. ) has content   -next ( 0)   this ( 0)
# 2. } has content   -next (-1)   this ( 0)
# 2. ] has content   -next (-2)   this ( 0)
#      line end:      next ( 0)   this ( 0)
# net next: 0
# net this: 0
[{
  :one => your_thing(1) }]

# 1. [ has content  +next ( 1)   this ( 0)
# 1. { no content   +next ( 2)   this ( 0)
#      line end:     next ( 0)   this ( 0)
# 2. ( has content  +next ( 1)   this ( 0)
# 2. ) has content  -next ( 0)   this ( 0)
#      line end:     next ( 0)   this ( 0)
# 3. } no content   -next (-1)  -this (-1)
# 3. ] has content  -next (-2)   this (-1)
#      line end:     next ( 0)   this ( 0)
# net next: 0
# net this: -1
[{
  :one => your_thing(1)
}]

# 1. [ has content  +next ( 1)   this ( 0)
# 1. { no  content  +next ( 2)   this ( 0)
#      line end:     next ( 0)   this ( 0)
# 2. ( has content  +next ( 1)   this ( 0)
# 2. ) has content  -next ( 0)   this ( 0)
# 2. } has content  -next (-1)   this ( 0)
#      line end:     next ( 0)   this ( 0)
# 3. ] no  content  -next (-1)   this (-1)
#      line end:     next ( 0)   this ( 0)
# net next: 0
# net this: -1
[{
  :one => your_thing(1) }
]

# 1. [ has content  +next ( 1)   this ( 0)
# 1. { no  content  +next ( 2)   this ( 0)
#      line end:     next ( 0)   this ( 0)
# 2. ( no  content  +next ( 1)   this ( 0)
#      line end:     next ( 0)   this ( 0)
# 3.   NO TOKEN
#      line end:     next ( 0)   this ( 0)
# 4. ) no  content  -next (-1)   this (-1)
#      line end:     next ( 0)   this ( 0)
# 5. ] no  content  -next (-1)   this (-1)
# 5. } has content  -next (-1)   this ( 0)
#      line end:     next ( 0)   this ( 0)
# net next: 0
# net this: -2
[{
  :one => your_thing(
    1
  )
}]

# 1. [ no  content  +next ( 1)   this ( 0)
#      line end:     next ( 0)   this ( 0)    next valid: 2
# 2. { no  content  +next ( 1)   this ( 0)
#      line end:     next ( 0)   this ( 0)    next valid: 4
# 3. ( no  content  +next ( 1)   this ( 0)
#      line end:     next ( 0)   this ( 0)    next valid: 6
# 4.   NO TOKEN
#      line end:     next ( 0)   this ( 0)    next valid: 6
# 5. ) no  content  -next (-1)   this (-1)
#      line end:     next ( 0)   this ( 0)    next valid: 4
# 6. } no  content  -next (-1)   this (-1)
#      line end:     next ( 0)   this ( 0)    next valid: 2
# 7. ] no  content  -next (-1)   this (-1)
#      line end:     next ( 0)   this ( 0)    next valid: 0
# net next: 0
# net this: -2
[
  {
    :one => your_thing(
      1
    )
  }
]

# rule:
# if double_token_opener or closer has content inside of it on that line
# 

result = Integer(
  String.new(
    "1"
  ).to_i,
    16
)

result = Integer(
  String.new(
    "1"
  ).to_i,

1 +
  String.
    new("1") +
    String.
      new("2") -
      17 +
      [1, 2, 3].inject(:+) *
       14

1 +
  String.
    new("1") +
  String.
    new("1") -
  17 +
  [1, 2, 3].
    inject(:+) *
  14

[{ :one => your_thing(
  1, def one
    puts "hi"
  end)
}
]
=end
