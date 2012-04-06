require_relative 'logger'
require_relative 'problem'
require_relative 'runtime_error'

class Tailor
  class Ruler
    include Tailor::Logger::Mixin

    attr_reader :cli_option

    def initialize(config={})
      @config = config
      @problems = []
      @child_rulers = []
      @cli_option = ""
      @do_measurement = true
      log "Ruler initialized with style setting: #{@config}"
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

    # Each ruler should redefine this for its needs.
    def measure(*args)
      raise RuntimeError,
        "Ruler#measure called, but should be redefined by a real ruler."
    end
  end
end
