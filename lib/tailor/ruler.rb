require_relative 'logger'
require_relative 'problem'

class Tailor
  class Ruler
    include LogSwitch::Mixin

    attr_reader :cli_option
    
    def initialize(config={})
      @config = config
      @problems = []
      @child_rulers = []
      @cli_option = ""
    end

    def add_child_ruler(ruler)
      @child_rulers << ruler
      log "Added child: #{ruler}"
    end

    def problems
      @problems = @child_rulers.inject(@problems) do |problems, ruler|
        problems + ruler.problems
      end

      @problems.sort_by! { |problem| problem[:line].to_i }
    end

    #---------------------------------------------------------------------------
    # Privates!
    #---------------------------------------------------------------------------
    private

    def log(*args)
      args.first.insert(0, "<#{self.class}> ")
      Tailor::Logger.log(*args)
    end
  end
end
