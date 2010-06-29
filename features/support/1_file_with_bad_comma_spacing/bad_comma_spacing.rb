# Perfect spacing after a comma, in comment and method
def do_something this, that, other
  puts "We, I mean I, am doing, er, something!"
end

# More than one space,  after a comma,  in a comment & method
def do_something this,  that,   other
  puts "We,  I mean I,  am doing,  er, something!"
end

# No space,after a comma,in a comment & method
def do_something this,that,other
  puts "We,I mean I ,am doing,er   ,something!"
end

# Spaces , before a comma ,in a comment & method
def do_something this , that ,other
  puts "We , I mean I ,am doing ,er   , something!"
end

# Perfect spacing around a comma, in an array
thing = [ 1,  2,  3 ]

# More than one space, after elements in an array
thing = [ 1,  2,  3 ]

# No space, after elements in an array
thing = [ 1,2,3 ]

# Spaces, before elements in an array
thing = [ 1 , 2  ,3 ]

# Perfect spacing around a comma, in a hash
thing = { :one => 1, :two => 2, :three => 3 }

# More than one space, after elements in a hash
thing = { :one => 1,  :two => 2,   :three => 3 }

# No space, after elements in an array
thing = { :one => 1,:two => 2,:three => 3 }

# Spaces, before elements in an array
thing = { :one => 1 , :two => 2  , :three => 3 }
