require_relative '../tailor'
require_relative 'logger'

class Tailor

  # Pulls in any configuration from the places configuration can be set:
  #   1. ~/.tailorrc
  #   2. CLI options
  #   3. Default options
  #
  # It then basically represents a list of "file sets" and the rulers that
  # should be applied against each file set.
  class Configuration
    include LogSwitch::Mixin

    DEFAULT_GLOB = 'lib/**/*.rb'
    DEFAULT_RC_FILE = Dir.home + '/.tailorrc'
    DEFAULT_STYLE = {
      allow_camel_case_methods: false,
      allow_hard_tabs: false,
      allow_screaming_snake_case_classes: false,
      allow_trailing_line_spaces: false,
      indentation_spaces: 2,
      max_code_lines_in_class: 300,
      max_code_lines_in_method: 30,
      max_line_length: 80,
      spaces_after_comma: 1,
      spaces_before_comma: 0,
      spaces_before_lbrace: 1,
      spaces_after_lbrace: 1,
      spaces_before_rbrace: 1,
      spaces_in_empty_braces: 0,
      spaces_after_lbracket: 0,
      spaces_before_rbracket: 0,
      spaces_after_lparen: 0,
      spaces_before_rparen: 0,
      trailing_newlines: 1
    }
    
    # @return [Hash]
    def self.default
      new
    end
    
    attr_reader :file_sets

    # @param [Array] runtime_file_list
    # @param [OpenStruct] options
    # @option options [String] config_file
    # @option options [Array] formatters
    # @option options [Hash] style
    def initialize(runtime_file_list=nil, options=nil)
      @formatters = ['text']
      @file_sets = {
        default: {
          file_list: file_list(DEFAULT_GLOB),
          style: DEFAULT_STYLE
        }
      }

      @runtime_file_list = runtime_file_list
      @options = options
      log "Got options: #{@options}"
    end

    # Call this to load settings from the config file and from CLI options.
    def load!
      # Get config file settings
      @config_file = @options.config_file unless @options.config_file.empty?
      load_from_config_file(config_file)
      
      if @rc_file_config
        # Get formatters from config file
        unless @rc_file_config.formatters.empty?
          @formatters = @rc_file_config.formatters
          log "@formatters is now #{@formatters}"
        end

        # Get file sets from config file
        unless @rc_file_config.file_sets.empty?
          @file_sets[:default].merge!(@rc_file_config.file_sets[:default])
          @rc_file_config.file_sets.delete(:default)

          @rc_file_config.file_sets.each do |file_set|
            @file_sets[file_set.key] = file_set.value
          end
        end
      end
      
      # Get formatters from CLI options
      unless @options.formatters.empty? || @options.formatters.nil?
        @formatters = @options.formatters
        log "@formatters is now #{@formatters}"
      end
      
      # Get file sets from CLI options
      unless @runtime_file_list.nil?
        @file_sets.delete_if { |k,v| k != :default }
        @file_sets[:default][:file_list] = file_list(@runtime_file_list)
      end
      
      # Get style overrides from CLI options
      @file_sets[:default][:style].merge!(@options.style)
      
      if @file_sets[:default][:file_list].empty?
        @file_sets[:default][:file_list] = file_list(DEFAULT_GLOB)
      end
    end

    # @return [String] Name of the config file to use.
    def config_file
      @config_file ||= DEFAULT_RC_FILE
    end

    # @return [Array] The list of formatters.
    def formatters(*new_formatters)
      @formatters = new_formatters unless new_formatters.empty?

      @formatters
    end

    # @param [Symbol] label The label that represents the file set.
    # @param [String] file_glob The String that represents the file set.  This
    #   can be a file, directory, or a glob.
    def file_set(label=:default, file_glob=DEFAULT_GLOB, &block)
      log "file set label #{label}"

      @temp_style = {}
      instance_eval(&block) if block_given?
      
      @file_sets[label] = {
        file_list: file_list(file_glob),
        style: DEFAULT_STYLE.merge(@temp_style)
      }
      @temp_style = {}
    end

    # Implemented for {file_set}, this converts the config file lines that look
    # like methods into a Hash.
    #
    # @return [Hash] The new style as defined by the config file.
    def method_missing(meth, *args, &blk)
      ok_methods = DEFAULT_STYLE.keys

      if ok_methods.include? meth
        @temp_style[meth] = args.first
      else
        super(meth, args, blk)
      end
    end

    # Tries to open the file at the path given at +config_file+ and read in
    # the configuration given there.
    #
    # @param [String] config_file Path to the config file to use.
    def load_from_config_file(config_file)
      user_config_file = File.expand_path(config_file)

      if File.exists? user_config_file
        log "<#{self.class}> Loading config from file: #{user_config_file}"
        config = instance_eval File.read(user_config_file)
      else
        log "<#{self.class}> No config file found at #{user_config_file}."
      end

      if config
        log "<#{self.class}> Got new config from file: #{config}"
        @rc_file_config = config
      end
    end

    # The list of the files in the project to check.
    #
    # @param [String] glob Path to the file, directory or glob to check.
    # @return [Array] The list of files to check.
    def file_list(glob)
      if glob.is_a? Array
        files_in_project = glob
      elsif File.directory? glob
        files_in_project = Dir.glob(File.join('*', '**', '*'))
        Dir.glob(File.join('*')).each { |file| files_in_project << file }
      else
        files_in_project = Dir.glob glob
      end

      list_with_absolute_paths = []

      files_in_project.each do |file|
        list_with_absolute_paths << File.expand_path(file)
      end

      list_with_absolute_paths.sort
    end

    def show
      table = Text::Table.new(horizontal_padding: 4)
      table.head = [{ value: 'Configuration', colspan: 2, align: :center }]
      table.rows << :separator
      table.rows << ['Style', @file_sets.inspect]
      table.rows << :separator
      table.rows << ['Formatters', @formatters]


      puts table
    end
  end
end
