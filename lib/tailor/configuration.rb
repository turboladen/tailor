require_relative '../tailor'
require_relative 'logger'
require_relative 'runtime_error'
require_relative 'configuration/style'
require_relative 'configuration/file_set'

class Tailor

  # Pulls in any configuration from the places configuration can be set:
  #   1. ~/.tailorrc
  #   2. CLI options
  #   3. Default options
  #
  # It then basically represents a list of "file sets" and the rulers that
  # should be applied against each file set.
  #
  # If a file list is given from the CLI _and_ a configuration file is
  # given/found, tailor uses the style settings for the default file set and
  # only checks the default file set.
  class Configuration
    include Tailor::Logger::Mixin

    DEFAULT_RC_FILE = Dir.home + '/.tailorrc'
    DEFAULT_PROJECT_CONFIG = Dir.pwd + '/.tailor'

    # @return [Hash]
    def self.default
      new
    end

    # @return [Hash]
    attr_reader :file_sets

    # @return [Array]
    attr_reader :formatters

    # @return [String]
    attr_reader :output_file

    # @param [Array] runtime_file_list
    # @param [OpenStruct] options
    # @option options [String] config_file
    # @option options [Array] formatters
    # @option options [Hash] style
    def initialize(runtime_file_list=nil, options=nil)
      @formatters = %w[text]
      @file_sets = {}
      @output_file = ''
      @runtime_file_list = runtime_file_list
      log "Got runtime file list: #{@runtime_file_list}"

      @options = options
      log "Got options: #{@options}"

      unless @options.nil?
        @config_file = @options.config_file unless @options.config_file.empty?
      end
    end

    # Call this to load settings from the config file and from CLI options.
    def load!
      if config_file
        load_from_config_file(config_file)

        if @config_from_file
          get_formatters_from_config_file
          #get_file_sets_from_config_file unless @runtime_file_list
          get_file_sets_from_config_file
        end
      else
        log 'Creating default file set...'
        @file_sets = { default: FileSet.new(@runtime_file_list) }
      end

      get_output_file_from_cli_opts
      get_formatters_from_cli_opts
      get_file_sets_from_cli_opts
      get_style_from_cli_opts
    end

    # Tries to open the file at the path given at +config_file+ and read in
    # the configuration given there.
    #
    # @param [String] config_file Path to the config file to use.
    def load_from_config_file(config_file)
      user_config_file = File.expand_path(config_file)

      if File.exists? user_config_file
        log "Loading config from file: #{user_config_file}"

        begin
          @config_from_file =
            instance_eval(File.read(user_config_file), user_config_file)
          log "Got new config from file: #{user_config_file}"
        rescue LoadError
          raise Tailor::RuntimeError,
            "Couldn't load config file: #{user_config_file}"
        end
      else
        abort "No config file found at #{user_config_file}."
      end
    end

    # @return [String] Name of the config file to use.
    def config_file
      return @config_file if @config_file

      if File.exists?(DEFAULT_PROJECT_CONFIG)
        return @config_file = DEFAULT_PROJECT_CONFIG
      end

      if File.exists?(DEFAULT_RC_FILE)
        return @config_file = DEFAULT_RC_FILE
      end
    end

    def get_file_sets_from_config_file
      return if @config_from_file.file_sets.empty?

      @config_from_file.file_sets.each do |label, file_set|
        log "label: #{label}"
        log "file set file list: #{file_set[:file_list]}"
        log "file set style: #{file_set[:style]}"

        if @file_sets[label]
          log 'label already exists.  Updating...'
          @file_sets[label].update_file_list(file_set[:file_list])
          @file_sets[label].update_style(file_set[:style])
        else
          log "Creating new label: #{label}"
          @file_sets[label] =
            FileSet.new(file_set[:file_list], file_set[:style])
        end
      end
    end

    def get_formatters_from_config_file
      return if @config_from_file.formatters.empty?

      @formatters = @config_from_file.formatters
      log "@formatters is now #{@formatters}"
    end

    def get_style_from_cli_opts
      return unless @options && @options.style

      @options.style.each do |property, value|
        @file_sets.keys.each do |label|
          if value == :off || value == 'off'
            @file_sets[label].style[property][1] = { level: :off }
          else
            @file_sets[label].style[property][0] = value
          end
        end
      end
    end

    # If any files are given from the CLI, this gets that list of files and
    # replaces those in any :default file set.
    def get_file_sets_from_cli_opts
      return if @runtime_file_list.nil? || @runtime_file_list.empty?

      # Only use options set for the :default file set because the user gave
      # a different set of files to measure.
      @file_sets.delete_if { |k, _| k != :default }

      if @file_sets.include? :default
        @file_sets[:default].file_list = @runtime_file_list
      else
        @file_sets = { default: FileSet.new(@runtime_file_list) }
      end
    end

    def get_output_file_from_cli_opts
      unless @options.nil? || @options.output_file.empty? || @options.output_file.nil?
        @output_file = @options.output_file
        log "@output_file is now: '#{@output_file}'"
      end
    end

    def get_formatters_from_cli_opts
      unless @options.nil? || @options.formatters.empty? || @options.formatters.nil?
        @formatters = @options.formatters
        log "@formatters is now: '#{@formatters}'"
      end
    end

    # @return [Array] The list of formatters.
    def formatters(*new_formatters)
      @formatters = new_formatters unless new_formatters.empty?

      @formatters
    end

    # Adds a file set to the list of file sets in the Configuration object.
    #
    # @param [String] file_expression The String that represents the file set.  This
    #   can be a file, directory, or a (Ruby Dir) glob.
    # @param [Symbol] label The label that represents the file set.
    def file_set(file_expression='lib/**/*.rb', label=:default)
      log "file sets before: #{@file_sets}"
      log "file set label #{label}"
      new_style = Style.new

      yield new_style if block_given?

      @file_sets[label] = FileSet.new(file_expression, new_style)
      log "file sets after: #{@file_sets}"
    end

    # A helper to #file_set that allows you to specify '*.rb' to get all files
    # ending with +.rb+ in your current path and deeper.
    #
    # @param [String] file_expression The expression to match recursively.
    # @param [Symbol] label The file set label to use.
    def recursive_file_set(file_expression, label=:default)
      file_set("*/**/#{file_expression}", label) do |style|
        yield style if block_given?
      end
    end

    # Displays the current configuration as a text table.
    def show
      table = Text::Table.new(horizontal_padding: 4)
      table.head = [{ value: 'Configuration', colspan: 2, align: :center }]
      table.rows << :separator
      table.rows << ['Formatters', @formatters]
      table.rows << ['Output File', @output_file]

      @file_sets.each do |label, file_set|
        table.rows << :separator
        table.rows << ['Label', label]
        table.rows << ['Style', '']
        file_set[:style].each do |k, v|
          table.rows << ['', "#{k}: #{v}"]
        end

        table.rows << ['File List', '']
        file_set[:file_list].each { |file| table.rows << ['', file] }
      end

      puts table
    end
  end
end
