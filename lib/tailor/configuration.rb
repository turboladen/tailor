require 'yaml'
require_relative 'logger'

class Tailor

  # Pulls in any configuration from the places configuration can be set:
  #   1. ~/.tailorrc
  #   2. CLI options
  #   3. Default options
  class Configuration
    include LogSwitch::Mixin

    DEFAULT_RC_FILE = Dir.home + '/.tailorrc'

    attr_reader :style
    attr_reader :file_list
    attr_reader :formatters

    def initialize(path_to_check, options={})
      @style = default_style
      @formatters = ['text']
      @options = options

      config_file = options[:config_file] || DEFAULT_RC_FILE
      load_from_file(config_file)
      @file_list = file_list(path_to_check)
    end

    def load_from_file(config_file)
      user_config_file = File.expand_path(config_file)

      config = if File.exists? user_config_file
        log "<#{self.class}> Loading configuration from file: #{user_config_file}"
        YAML.load_file user_config_file
      end

      if config
        log "<#{self.class}> Got new config from file: #{config}"
        @style.merge! config[:style] if config.has_key? :style
        @formatters = config[:format] if config.has_key? :format
      end
    end

    # The list of the files in the project to check.
    #
    # @param [String] path Path to the file or directory to check.
    # @return [Array] The list of files to check.
    def file_list(path=nil)
      return @file_list if @file_list

      if path.nil?
        return ['']
      end

      if File.directory? path
        FileUtils.cd path
      else
        return [path]
      end

      files_in_project = Dir.glob(File.join('*', '**', '*'))
      Dir.glob(File.join('*')).each { |file| files_in_project << file }

      list_with_absolute_paths = []

      files_in_project.each do |file|
        if File.file? file
          list_with_absolute_paths << File.expand_path(file)
        end
      end

      @file_list = list_with_absolute_paths.sort
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

    private

    def default_style
      {
        horizontal_spacing: {
          allow_hard_tabs: false,
          allow_trailing_spaces: false,
          indent_spaces: 2,
          line_length: 80,
          spaces_after_comma: 1,
          spaces_before_comma: 0
        },
        names: {
          allow_camel_case_methods: false,
          allow_screaming_snake_case_classes: false
        },
        vertical_spacing: {
          trailing_newlines: 1
        }
      }
    end
  end
end
