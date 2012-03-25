require_relative 'logger'
require_relative 'problem'

class Tailor
  class Ruler
    include LogSwitch::Mixin

    def initialize(config={})
      @config = config
      @problems = []
      @child_rulers = []
    end
    
    def add_child_ruler(ruler)
      @child_rulers << ruler
    end
    
    def problems
      @problems = @child_rulers.inject(@problems) do |problems, ruler|
        problems + ruler.problems
      end
      
      @problems
    end
  end
end
