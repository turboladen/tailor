require_relative '../ruler'

class Tailor
  module Rulers
    class CamelCaseMethodRuler < Tailor::Ruler
      def ident_update(token, lexed_line, lineno, column)
        ident_index = lexed_line.event_index(column)
        previous_event = lexed_line.event_at(ident_index - 2)
        log "previous event: #{previous_event}"

        return if previous_event.nil?

        if previous_event[1] == :on_kw && previous_event.last == "def"
          check_camel_case_method_name(token, lineno, column)
        end
      end

      def check_camel_case_method_name(token, lineno, column)
        if token =~ /[A-Z]/
          @problems << Problem.new(:camel_case_method, lineno, column)
        end
      end
    end
  end
end
