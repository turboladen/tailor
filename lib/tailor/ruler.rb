require_relative 'logger'
require_relative 'problem'
require_relative 'runtime_error'
require_relative '../ext/string_ext'

class Tailor

  # This is a composite class, geared for getting at or managing the Rulers
  # that should be used for measuring style.  To do so, create a new object of
  # this type, then add child rulers to that object using +#add_child_ruler+.
  # After using the Ruler, you'll have access to all of the problems found by
  # all of the child rulers via +#problems+.
  #
  # Example:
  #   ruler = Ruler.new
  #   file_length_ruler = FileLengthRuler.new
  #   ruler.add_child_ruler(file_length_ruler)
  #   # use ruler
  #   ruler.problems      # => [{ all of your file length problems... }]
  #
  # There's really no measuring functionality in this base class--it's merely
  # for aggregating child data and for providing a base class to create child
  # Rulers from.  Speaking of... if you want, you can create your own rulers.
  # A Ruler requires a few things:
  #
  # First, it needs a list of Lexer events to observer.  Tailor uses its Lexer
  # to publish events (in this case, characters or string Ruby constructs) of
  # interest to its observers.  Rulers subscribe to those events so that they
  # can detect the problems they're looking for.  These are defined as a Set in
  # +@lexer_observers+.  Adding to that list means the Ruler will subscribe to
  # those events.
  #
  # Example:
  #   class MyRuler < Tailor::Ruler
  #     def initialize
  #       add_lexer_observers = :nl_observer, :kw_observer
  #     end
  #   end
  class Ruler
    include Tailor::Logger::Mixin

    attr_reader :lexer_observers

    # @param [Object] config
    # @param [Hash] options
    def initialize(config=nil, options={ level: :error })
      @config = config
      @options = options
      @do_measurement = true
      log "Ruler initialized with style setting: #{@config}"
      log "Ruler initialized with problem level setting: #{@options[:level]}"

      @child_rulers = []
      @lexer_observers = []
      @problems = []
    end

    # Adds the {Tailor::Ruler} object to the list of child rulers.
    #
    # @param [Tailor::Ruler] ruler
    def add_child_ruler(ruler)
      @child_rulers << ruler
      log "Added child ruler: #{ruler}"
    end

    # Gets all of the problems from all child rulers.
    #
    # @return [Array] The list of problems.
    def problems
      @problems = @child_rulers.inject(@problems) do |problems, ruler|
        problems + ruler.problems
      end

      @problems.sort_by! { |problem| problem[:line].to_i }
    end

    # Each ruler should redefine this for its needs.
    def measure(*args)
      raise RuntimeError,
        'Ruler#measure called, but should be redefined by a real ruler.'
    end

    # Converts the {Tailor::Ruler} name to snake case.
    #
    # @return [String] The ruler name as snake-case that represents the problem
    #   that was found.
    def problem_type
      self.class.to_s =~ /^.+::(\S+)Ruler$/

      $1.underscore
    end

    private

    def add_lexer_observers(*lexer_observer)
      @lexer_observers = lexer_observer
    end
  end
end
