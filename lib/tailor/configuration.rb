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
    end

    def load!
      config_file = @options.config_file unless @options.config_file.empty?
      @config_file_options = load_from_config_file(config_file)
      @formatters = unless @config_file_options[:formatters].empty?
        @config_file_options[:formatters]
      end
      
      unless @config_file_options[:file_sets].empty?
        @file_sets[:default].merge!(@config_file_options[:file_sets][:default])
        @config_file_options.delete(:default)
        
        @config_file_options[:file_sets].each do |file_set|
          @file_sets[file_set.key] = file_set.value
        end
      end
      #@formatters = init_formatters(@options.formatters)
      #@file_sets = init_file_sets(@runtime_file_list, @options.style)
    end

    # @return [String] Name of the config file to use.
    def config_file
      @config_file ||= DEFAULT_RC_FILE
    end

    def config_file=(new_config_file)
      # Anything at runtime?
      return config_file unless config_file.empty?
      
      @config_file = new_config_file
    end

    # @return [Array<Hash>] The list of file sets to use.
=begin
    def init_file_sets(runtime_file_list, runtime_style)
      style = init_style(runtime_style)
      log "Style inited: #{style}"

      # Anything from the rc file?
      if @config_file_options
        log "Got config file options..."

        unless @config_file_options.file_sets.empty?
          @file_sets = @config_file_options.file_sets.tap do |file_sets|
            file_sets.each do |label, file_set|
              log "file set label #{label}"
              log "file set #{file_set}"

              {
                label => {
                  file_list: file_list(file_set[:file_list]),
                  style: style
                }
              }
            end
          end
        end
      end

      # Anything at runtime?
      unless runtime_file_list.empty?
        if runtime_file_list.size == 1
          @file_sets[:default][:file_list] = file_list(runtime_file_list.first)
        else
          runtime_file_list
        end
      end
    end
=end

    # @return [Array] The list of formatters to use.
=begin
    def init_formatters(formatters)
      # Anything from the rc file?
      if @config_file_options
        unless @config_file_options.formatters.nil?
          unless @config_file_options.formatters.empty?
            @formatters = @config_file_options.formatters
          end
        end
      end

      # Anything at runtime?
      unless formatters.empty?
        @formatters = formatters
        return
      end
    end
=end

    def formatters(new_formatters=nil)
      @formatters = new_formatters unless new_formatters.nil?

      @formatters
    end

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

      config = if File.exists? user_config_file
                 log "<#{self.class}> Loading config from file: #{user_config_file}"
                 instance_eval File.read(user_config_file)
               else
                 log "<#{self.class}> No config file found at #{user_config_file}."
               end

      if config
        log "<#{self.class}> Got new config from file: #{config}"
        @config_file_options = config
      end
    end

    # The list of the files in the project to check.
    #
    # @param [String] glob Path to the file, directory or glob to check.
    # @return [Array] The list of files to check.
    def file_list(glob)
      if File.directory? glob
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
      table.rows << ['Style', @style.inspect]
      table.rows << :separator
      table.rows << ['Formatters', @formatters]


      puts table
    end
  end
end
