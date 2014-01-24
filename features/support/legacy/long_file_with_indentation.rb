# This file contains 1 method, no class, and is properly indented
#   in order to test a related scenario.
module MyModule

  # This is a class!
  class AnotherThing

    # This is a method!
    def a_method
      case
      when 1
        1..10.each { |num| puts num }
      when 2
      else
        while false
          # Don't do anything
          # And stuff
          "meow".scan(/woem/)
          array = [1 ,2 ,3]
          other_thing = [
            4,
            5,
            6
          ]
        end
      end

      an_array = Array.new
      a_hash = Hash.new

      # This is another comment
      an_array = [1, 2, 3]
      a_hash = {
        one: 1,
        two: 2
      }

      if true
        # Let's return!
        return true
      elsif false
        return false
      else
        return nil
      end

      # Now how about a block...
      1..10.times do |number|
        begin
        rescue
        ensure
        end
      end
    end
  end
end
