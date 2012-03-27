require_relative '../rulers'

class Tailor
  class Critic
    module VerticalSpacingRulerInitializers
      include Tailor::Rulers
      
      def init_trailing_newline_ruler(v_spacing_ruler, lexer)
        if @config[:vertical_spacing][:trailing_newlines]
          trailing_newline_ruler = TrailingNewlineRuler.new(
            @config[:vertical_spacing][:trailing_newlines]
          )
          v_spacing_ruler.add_child_ruler(trailing_newline_ruler)
          lexer.add_file_observer(trailing_newline_ruler)
        end
      end
    end
  end
end
