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
  class Configuration
    include Tailor::Logger::Mixin

    DEFAULT_RC_FILE = Dir.home + '/.tailorrc'
    DEFAULT_PROJECT_CONFIG = Dir.pwd + '/.tailor'

    # @return [Hash]
    def self.default
      new
    end

    attr_reader :file_sets
    attr_reader :formatters

    # @param [Array] runtime_file_list
    # @param [OpenStruct] options
    # @option options [String] config_file
    # @option options [Array] formatters
    # @option options [Hash] style
    def initialize(runtime_file_list=nil, options=nil)
      #@style = Style.new
      @formatters = ['text']
=begin
      @file_sets = {
        default: {
          file_list: file_list(DEFAULT_GLOB),
          style: @style.to_hash
        }
      }
=end
      @file_sets = { default: FileSet.new }

      @runtime_file_list = runtime_file_list
      log "Got runtime file list: #{@runtime_file_list}"
      @options = options
      log "Got options: #{@options}"
    end

    # Call this to load settings from the config file and from CLI options.
    def load!
      # Get config file settings
      unless @options.nil?
        @config_file = @options.config_file unless @options.config_file.empty?
      end

      load_from_config_file(config_file) if config_file

      if @config_file
        if @rc_file_config
          get_formatters_from_config_file
          get_file_sets_from_config_file
        end
      end

      get_formatters_from_cli_opts
      get_files_sets_from_cli_opts
      get_style_from_cli_opts
=begin

      if @file_sets[:default][:file_list].empty?
        @file_sets[:default][:file_list] = file_list(DEFAULT_GLOB)
      end
=end
    end

    def get_file_sets_from_config_file
      unless @rc_file_config.file_sets.empty?
        @rc_file_config.file_sets.each do |label, file_set|
          log "file set: #{file_set}"

          if @file_sets[label]
            #@file_sets[label][:file_list].concat file_set[:file_list]
            #@file_sets[label][:file_list].uniq!
            @file_sets[label].update_file_list(file_set[:file_list])
            #@file_sets[label][:style].merge! file_set[:style]
            @file_sets[label].update_style(file_set[:style])
          else
=begin
            @file_sets[label] = {
              file_list: file_set[:file_list],
              style: @style.to_hash.merge(file_set[:style])
            }
=end
            @file_sets[label] =
              FileSet.new(file_set[:style], file_set[:file_list])
          end
        end
      end
    end

    def get_formatters_from_config_file
      unless @rc_file_config.formatters.empty?
        @formatters = @rc_file_config.formatters
        log "@formatters is now #{@formatters}"
      end
    end

    def get_style_from_cli_opts
      if @options && @options.style
        @options.style.each do |property, value|
          if value == :off || value == "off"
            @file_sets[:default][:style][property][1] = { level: :off }
          else
            @file_sets[:default][:style][property][0] = value
          end
        end
      end
    end

    def get_files_sets_from_cli_opts
      unless @runtime_file_list.nil? || @runtime_file_list.empty?
        # Only use options set for the :default file set because the user gave
        # a different set of files to measure.
        @file_sets.delete_if { |k, v| k != :default }
        #@file_sets[:default][:file_list] = file_list(@runtime_file_list)
        @file_sets[:default].update_file_list(@runtime_file_list)
      end
    end

    def get_formatters_from_cli_opts
      unless @options.nil? || @options.formatters.empty? || @options.formatters.nil?
        @formatters = @options.formatters
        log "@formatters is now #{@formatters}"
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

    # @return [Array] The list of formatters.
    def formatters(*new_formatters)
      @formatters = new_formatters unless new_formatters.empty?

      @formatters
    end

    # Adds a file set to the list of file sets in the Configuration object.
    #
    # @param [String] file_glob The String that represents the file set.  This
    #   can be a file, directory, or a glob.
    # @param [Symbol] label The label that represents the file set.
    def file_set(file_glob='lib/**/*.rb', label=:default)
      log "file sets before: #{@file_sets}"
      log "file set label #{label}"

      new_style = Style.new

      if block_given?
        yield new_style

        if @file_sets[label]
          #@file_sets[label][:style].merge! new_style
          @file_sets[label].update_style(new_style)
        end
      end

      if @file_sets[label]
=begin
        @file_sets[label][:file_list].concat file_list(file_glob)
        @file_sets[label][:file_list].uniq!
=end
      else
=begin
        @file_sets[label] = {
          file_list: file_list(file_glob),
          style: @style.to_hash.merge(new_style)
        }
=end
        @file_sets[label] = FileSet.new(new_style)
      end

      log "file sets after: #{@file_sets}"
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
          config = instance_eval File.read(user_config_file)
        rescue LoadError => ex
          raise Tailor::RuntimeError,
            "Couldn't load config file: #{user_config_file}"
        end
      else
        log "No config file found at #{user_config_file}."
      end

      if config
        log "Got new config from file: #{config}"
        @rc_file_config = config
      end
    end


    # The list of the files in the project to check.
    #
    # @param [String] glob Path to the file, directory or glob to check.
    # @return [Array] The list of files to check.
    def file_list(glob)
=begin
      files_in_project = if glob.is_a? Array
        log "Configured glob is an Array: #{glob}"

        glob.map do |e|
          if File.directory?(e)
            all_files_in_dir(e)
          else
            e
          end
        end.flatten.uniq
      elsif File.directory? glob
        log "Configured glob is an directory: #{glob}"
        all_files_in_dir(glob)
      else
        log "Configured glob is a glob/single-file: #{glob}"
        Dir.glob glob
      end

      list_with_absolute_paths = []

      files_in_project.each do |file|
        list_with_absolute_paths << File.expand_path(file)
      end

      log "All files: #{list_with_absolute_paths}"

      list_with_absolute_paths.sort
=end

    end

    # Displays the current configuration as a text table.
    def show
      table = Text::Table.new(horizontal_padding: 4)
      table.head = [{ value: 'Configuration', colspan: 2, align: :center }]
      table.rows << :separator
      table.rows << ['Formatters', @formatters]

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
