# Blocks...
# No space after {
1..10.times {|number| puts number }

# No space before {
1..10.times{ |number| puts number }

# No space before or after {
1..10.times{|number| puts number }

# No space before }
1..10.times { |number| puts number}

# No space before or after { and }
1..10.times{|number| puts number}

# >1 space before {
1..10.times  { |number| puts number }

# >1 space after {
1..10.times {  |number| puts number }

# >1 space before, no spaces after {
1..10.times  {|number| puts number }

# >1 space after, no spaces before {
1..10.times{  |number| puts number }

# >1 space before }
1..10.times { |number| puts number  }

# Perfect
1..10.times { |number| puts number }


# Hashes...
# No space after {
thing = {:one => 1 }

# No space before {
thing ={ :one => 1 }

# No space before or after {
thing ={:one => 1 }

# No space before }
thing = { :one => 1}

# No space before or after { and }
thing ={:one => 1}

# Perfect
thing = { :one => 1 }

# Skip on default params in methods...
def a_method; one={}; end

# Skip on strings...
a_string = "This is a #{thing}..."
b_string = "This has #{Class.methods}"