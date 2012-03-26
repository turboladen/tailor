require_relative '../ruler'

class Tailor
  module Rulers
    class ScreamingSnakeCaseClassRuler < Tailor::Ruler
      def const_update(token, lexed_line, lineno, column)
        ident_index = lexed_line.event_index(column)
        previous_event = lexed_line.event_at(ident_index - 2)
        log "previous event: #{previous_event}"

        if previous_event[1] == :on_kw &&
          (previous_event.last == "class" || previous_event.last == "module")
          check_screaming_snake_case_class_name(token, lineno, column)
        end
      end

      def check_screaming_snake_case_class_name(token, lineno, column)
        if token =~ /[A-Z].*_/
          @problems << Problem.new(:screaming_snake_case_class_name,
            lineno, column)
        end
      end
    end
  end
end
