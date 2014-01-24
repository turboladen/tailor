require 'rake'
require 'rake/tasklib'
require_relative 'critic'
require_relative 'configuration'
require_relative 'logger'
require_relative 'cli'

begin
  # Support Rake > 0.8.7
  require 'rake/dsl_definition'
rescue LoadError
end

Tailor::Logger.log = false

class Tailor

  # This class lets you define Rake tasks to drive tailor.  Specifying options
  # is similar to specifying options in a configuration file.
  #
  # @example Use Tailor CLI Options
  #   Tailor::RakeTask.new do |task|
  #     task.tailor_opts = %w(--no-color --max-line-length=100)
  #   end
  #
  # @example A task specifically for features
  #   Tailor::RakeTask.new(:tailor_features) do |task|
  #     task.file_set 'features/**/*.rb', :features do |style|
  #       style.max_line_length 100, level: :warn
  #       style.trailing_newlines 2
  #     end
  #   end
  #
  # @example Use a configuration file
  #   Tailor::RakeTask.new do |task|
  #     task.config_file = 'hardcore_stylin.rb'
  #   end
  #
  # Note that prior to 1.1.4, you could use the #config_file option _and_
  # specify file_sets or recursive_file_sets; this caused problems (and
  # confusion), so the combination of these was removed in 1.2.0.  If you use
  # #config_file, then all file_sets and recursive_file_sets that you specify
  # in the Rake task will be ignored; only those specified in the given config
  # file will be used.
  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined? ::Rake::DSL

    # Use a specific configuration file.  If you have a .tailor file, your
    # RakeTask will automatically use that.
    #
    # @return [String] The path to the configuration file.
    attr_accessor :config_file

    # Specify any extra options (CLI options).  These will override any options
    # set in your config file.
    attr_accessor :tailor_opts

    # @return [Array] The list of formatters to use.  (not really used yet)
    attr_accessor :formatters

    # @param [String] name The task name.
    # @param [String] desc Description of the task.
    def initialize(name = 'tailor', desc = 'Check style')
      @name, @desc = name, desc
      @tailor_opts = []
      @file_sets = []
      @recursive_file_sets = []
      @config_file = nil

      yield self if block_given?

      define_task
    end

    # Add a file set to critique, just like you would in a config file.
    #
    # @param [String] file_expression
    # @param [Symbol] label
    def file_set(file_expression, label=:default, &block)
      @file_sets << [file_expression, label, block]
    end

    # Add a recursive file set to critique, just like you would in a config
    # file.
    #
    # @param [String] file_expression
    # @param [Symbol] label
    def recursive_file_set(file_expression, label=:default, &block)
      @recursive_file_sets << [file_expression, label, block]
    end

    private

    def define_task
      desc @desc
      task @name do
        if config_file
          @tailor_opts.concat %W(--config-file=#{config_file})
        end

        cli = Tailor::CLI.new(@tailor_opts)
        cli.configuration.file_sets
        create_file_sets_for cli.configuration
        create_recursive_file_sets_for cli.configuration

        begin
          failure = cli.execute!
          exit(1) if failure
        rescue Tailor::RuntimeError => ex
          STDERR.puts ex.message
          STDERR.puts ex.backtrace.join("\n")
        rescue SystemExit => ex
          exit(ex.status)
        rescue Exception => ex
          STDERR.puts("#{ex.message} (#{ex.class})")
          STDERR.puts(ex.backtrace.join("\n"))
          exit(1)
        end
      end
    end

    # @return [Tailor::Configuration]
    def create_config
      configuration = Tailor::Configuration.new([],
        Tailor::CLI::Options.parse!(@tailor_opts))
      configuration.load!

      unless formatters.nil? || formatters.empty?
        configuration.formatters(formatters)
      end

      configuration
    end

    # @param [Tailor::Configuration] config
    def create_recursive_file_sets_for(config)
      unless @recursive_file_sets.empty?
        @recursive_file_sets.each do |fs|
          config.recursive_file_set(fs[0], fs[1], &fs[2])
        end
      end
    end

    # @param [Tailor::Configuration] config
    def create_file_sets_for(config)
      unless @file_sets.empty?
        @file_sets.each { |fs| config.file_set(fs[0], fs[1], &fs[2]) }
      end
    end
  end
end
