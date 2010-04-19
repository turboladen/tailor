module RubyStyleChecker
  module IndentationChecker    
    def validate_indentation file
      results = Array.new
      
      source = File.open(file, 'r')
      
      # Start the line number at 1, not 0
      line_number = 1

      source.each_line do |line_of_code|
        line = FileLine.new(line_of_code)

        # Make sure the line isn't hard-tabbed
        if line.hard_tabbed? 
          results << "Line #{line_number} is hard-tabbed."
        end

        # Check for indentation
        #spaces = line.indented_spaces 
        #current_depth_level = spaces / 2

        line_number =+ 1
      end
    end
  end
end