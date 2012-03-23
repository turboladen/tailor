class Tailor
  module CompositeObservable
    def self.define_observer(name)
      define_method("add_#{name}_observer") do |observer, func|
        @notifiers = {} unless defined? @notifiers
        @notifiers[name] = {} unless @notifiers[name]

        call_back = func || :update

        unless observer.respond_to? func
          raise NoMethodError, "observer does not respond to '#{call_back}'"
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

    define_observer :kw
    define_observer :nl
  end
end

