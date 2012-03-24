require_relative 'logger'
require_relative 'problem'

class Tailor
  class Ruler
    include LogSwitch::Mixin

    attr_reader :problems

    def initialize(config)
      @config = config
      @problems = []
    end
  end
end
