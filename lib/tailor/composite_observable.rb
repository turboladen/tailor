class Tailor
  module CompositeObservable
    def self.define_observer(name)
      define_method("add_#{name}_observer") do |observer|
        @notifiers = {} unless defined? @notifiers
        @notifiers[name] = {} unless @notifiers[name]

        call_back = "#{name}_update".to_sym

        unless observer.respond_to? call_back
          raise NoMethodError, "observer '#{observer}' does not respond to '#{call_back}'"
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
