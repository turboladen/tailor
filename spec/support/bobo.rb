def dostuff(duck) 
raise "The duck '#{duck}' should be able to :quack" unless duck.respond_to? :quack 
do_deeper_stuff(duck) 
end 
def do_deeper_stuff(duck) 
do_really_deep_stuff(duck) 
end 
def do_really_deep_stuff(duck) 
duck.quack 
end

