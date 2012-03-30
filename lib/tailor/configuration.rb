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

    attr_reader :file_sets
    attr_reader :formatters

    # @return [Hash]
    def self.default
      {
        file_sets: [
          file_list: DEFAULT_GLOB,
          style: {
            allow_camel_case_methods: false,
            allow_hard_tabs: false,
            allow_screaming_snake_case_classes: false,
            allow_trailing_line_spaces: false,
            indentation_spaces: 2,
            line_length: 80,
            max_code_lines_in_class: 300,
            max_code_lines_in_method: 30,
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
        ],
        formatters: ['text']
      }
    end

    # @param [Array] runtime_file_list
    # @param [OpenStruct] options
    # @option options [String] config_file
    # @option options [Array] formatters
    # @option options [Hash] style
    def initialize(runtime_file_list=nil, options=nil)
      config_file = init_config_file(options.config_file)
      @config_file_options = load_from_config_file(config_file)
      @formatters = init_formatters(options.formatters)
      @file_sets = init_file_sets(runtime_file_list, options.style)
    end

    # @return [Hash] The style Hash to use.
    def init_style(runtime_style)
      style = Configuration.default[:file_sets].first[:style]
      style.merge!(style) unless runtime_style.empty?

      style
    end

    # @return [Array<Hash>] The list of file sets to use.
    def init_file_sets(runtime_file_list, runtime_style)
      style = init_style(runtime_style)

      # Anything at runtime?
      unless runtime_file_list.empty?
        files = if runtime_file_list.size == 1
          file_list(runtime_file_list.first)
        else
          runtime_file_list
        end
        return [{ files: files, style: style }]
      end

      # Anything from the rc file?
      if @config_file_options
        log "Got config file options..."
        
        unless @config_file_options[:file_sets].empty?
          return @config_file_options[:file_sets].tap do |file_sets|
            file_sets.each do |file_set|
              log "file set #{file_set}"
              file_set[:file_list] = file_list(file_set[:file_list])
            end
          end
        end
      end

      # Use defaults
      [{ files: file_list(DEFAULT_GLOB), style: Configuration.default[:style] }]
    end

    # @return [Array] The list of formatters to use.
    def init_formatters(formatters)
      # Anything at runtime?
      unless formatters.empty?
        return formatters
      end

      # Anything from the rc file?
      if @config_file_options
        unless @config_file_options[:formatters].empty?
          return @config_file_options[:formatters]
        end
      end

      # Use defaults
      ['text']
    end

    # @return [String] Name of the config file to use.
    def init_config_file(config_file)
      # Anything at runtime?
      unless config_file.empty?
        return config_file
      end

      return DEFAULT_RC_FILE
    end

    def load_from_config_file(config_file)
      user_config_file = File.expand_path(config_file)

      config = if File.exists? user_config_file
        log "<#{self.class}> Loading config from file: #{user_config_file}"
        instance_eval File.read(user_config_file)
      end

      if config
        log "<#{self.class}> Got new config from file: #{config}"
        @config_file_options = config
      end
    end

    # The list of the files in the project to check.
    #
    # @param [String] path Path to the file, directory or glob to check.
    # @return [Array] The list of files to check.
    def file_list(path=nil)
=begin
      if path.nil?
        return ['']
      end
=end
      #if path.nil?
      #  return Dir.glob(DEFAULT_GLOB)
      #end

      if File.directory? path
        log "path is a directory"
        FileUtils.cd path
        
        files_in_project = Dir.glob(File.join('*', '**', '*'))
        Dir.glob(File.join('*')).each { |file| files_in_project << file }
      elsif File.file? path
        log "path is a file"
        return [path]
      else 
        log "path is a glob"
        files_in_project = Dir.glob path
      end

      list_with_absolute_paths = []

      files_in_project.each do |file|
        if File.file? file
          list_with_absolute_paths << File.expand_path(file)
        end
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
