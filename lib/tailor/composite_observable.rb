class Tailor

  # Used by {Tailor::Lexer} to provide publishing methods for observers.
  # Any Ruler that wants to subscribe to Lexer events must use the methods
  # defined here.
  module CompositeObservable

    # Defines three instance methods that provide for observing a
    # {Tailor::Lexer} object.  If +name+ was passed "test":
    #
    # * +#add_test_observer+
    # * +#test_update+
    # * +#notify_test_observers+
    #
    # @param [String] name The name of event to observe/subscribe to.
    def self.define_observer(name)
      define_method("add_#{name}_observer") do |observer|
        @notifiers = {} unless defined? @notifiers
        @notifiers[name] = {} unless @notifiers[name]

        call_back = "#{name}_update".to_sym

        unless observer.respond_to? call_back
          raise NoMethodError,
            "observer '#{observer}' does not respond to '#{call_back}'"
        end

        @notifiers[name][observer] = call_back
      end

      define_method("notify_#{name}_observers") do |*args|
        if defined? @notifier_state and @notifier_state
          if @notifier_state[name]
            if defined? @notifiers and @notifiers[name]
              @notifiers[name].each do |k, v|
                k.send(v, *args)
              end
            end
          end
        end
      end

      define_method("#{name}_changed") do
        @notifier_state = {} unless defined? @notifier_state
        @notifier_state[name] = true
      end
    end

    define_observer :comma
    define_observer :comment
    define_observer :const
    define_observer :embexpr_beg
    define_observer :embexpr_end
    define_observer :file_beg
    define_observer :file_end
    define_observer :ident
    define_observer :ignored_nl
    define_observer :kw
    define_observer :lbrace
    define_observer :lbracket
    define_observer :lparen
    define_observer :nl
    define_observer :period
    define_observer :rbrace
    define_observer :rbracket
    define_observer :rparen
    define_observer :sp
    define_observer :tstring_beg
    define_observer :tstring_end
  end
end
