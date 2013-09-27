require_relative 'lexer'
require_relative 'logger'
require_relative 'ruler'
require_relative 'rulers'


class Tailor

  # An object of this type provides for starting the process of critiquing
  # files.  It handles initializing the Ruler objects it needs based on the
  # configuration given to it.
  class Critic
    include LogSwitch::Mixin
    include Tailor::Rulers

    # The instance method that starts the process of looking for problems in
    # files.  It checks for problems in each file in each file set.  It yields
    # the problems found and the label they were found for.
    #
    # @param [Hash] file_sets The file sets to critique.
    # @yieldparam [Hash] problems The problems found for the label.
    # @yieldparam [Symbol] label The label the problems were found for.
    def critique(file_sets)
      log "file sets keys: #{file_sets.keys}"

      file_sets.each do |label, file_set|
        log "Critiquing file_set: #{file_set}"

        file_set[:file_list].each do |file|
          log "Critiquing file: #{file}"

          begin
            problems = check_file(file, file_set[:style])
          rescue => ex
            $stderr.puts "Error while parsing file #{file}"
            raise(ex)
          end

          yield [problems, label] if block_given?
        end
      end
    end

    # @return [Hash{String => Array}] The list of problems, where the keys are
    #   the file names in which the problems were found, and the values are the
    #   respective lists of problems for each file.
    def problems
      @problems ||= {}
    end

    # @return [Fixnum] The number of problems found so far.
    def problem_count(type=nil)
      if type.nil?
        problems.values.flatten.size
      else
        problems.values.flatten.find_all { |v| v[:level] == :error }.size
      end
    end

    # Adds problems found from Lexing to the +#problems+ list.
    #
    # @param [String] file The file to open, read, and check.
    # @return [Hash] The Problems for that file.
    def check_file(file, style)
      log "<#{self.class}> Checking style of file: #{file}."
      lexer = Tailor::Lexer.new(file)
      ruler = Ruler.new
      log 'Style:'
      style.each { |property, values| log "#{property}: #{values}" }
      init_rulers(style, lexer, ruler)

      lexer.lex
      problems[file] = ruler.problems

      { file => problems[file] }
    end

    private

    # Creates Rulers for each ruler given in +style+ and adds the Ruler's
    # defined observers to the given +lexer+.
    #
    # @param [Hash] style The Hash that defines the style to be measured
    #   against.
    # @param [Tailor::Lexer] lexer The Lexer object the Rulers should observe.
    # @param [Tailor::Ruler] parent_ruler The main Ruler to add the child
    #   Rulers to.
    def init_rulers(style, lexer, parent_ruler)
      style.each do |ruler_name, values|
        ruler = "Tailor::Rulers::#{camelize(ruler_name.to_s)}Ruler"

        if values.last[:level] == :off || values.last[:level] == 'off'
          msg = "Style option set to '#{values.last[:level]}'; "
          log msg << "skipping init of '#{ruler}'"
          next
        end

        log "Initializing ruler: #{ruler}"
        ruler = instance_eval("#{ruler}.new(#{values.first}, #{values.last})")
        parent_ruler.add_child_ruler(ruler)

        ruler.lexer_observers.each do |observer|
          log "Adding #{observer} to lexer..."
          meth = "add_#{observer}_observer".to_sym
          lexer.send(meth, ruler)
        end
      end
    end

    # Converts a snake-case String to a camel-case String.
    #
    # @param [String] string The String to convert.
    # @return [String] The converted String.
    def camelize(string)
      string.split(/_/).map { |word| word.capitalize }.join
    end
  end
end
