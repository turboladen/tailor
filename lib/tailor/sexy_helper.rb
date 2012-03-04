require 'ripper'
require 'awesome_print'

class Tailor
  class SexyHelper
    class << self

      # @param [Array] sexped_output The output from {Ripper.sexp}.
      # @return [Array] The cleaned up sexped Array.
      def sexp_cleanup(sexped_output)
        #sexped_output.delete_at(0).first
        sexped_output.delete_at(0)
        #puts "sexped output:"
        #p sexped_output
        #puts "sexped size: #{sexped_output.size}"
        if sexped_output.size == 1
          sexped_output.first
        else
          Tailor.log("<#{self}> Got sexped output of size other than 1.", :error)
          sexped_output
        end
      end

      # @param [Array] lexed_line_output Output of a single line of lexed source
      #   code.
      # @param [Array] sexped_file Output from {sexp} for a whole file.
      # @return [Array] The sexped output that represents the +lexed_line_output+.
      def lexed_line_converter(lexed_line_output, sexped_file)
        p lexed_line_output
        puts
        sexped_file.each_with_index do |s, i|
          Tailor.log "<#{self}> #{i}: #{s} "
          Tailor.log ""
        end
        Tailor.log "<#{self}> sexped array size: #{sexped_file.size}"
        line_number = lexed_line_number(lexed_line_output)
        Tailor.log "<#{self}> line number: #{line_number}"

        sexped_file.each do |element|
          if element.first.first == line_number
            sexped_line_output = element
          end
        end

        raise if sexped_line_output.nil?
        sexped_line_output
      end

      def sexp_for_line(file, line_number)

      end

      # @return [Fixnum] The line number that the passed-in lexed output
      #   represents.
      def lexed_line_number(lexed_line_output)
        l = lexed_line_output.first.first.first
        Tailor.log "<#{self}> lexed line num: #{l}"

        l
      end
    end
  end
end
