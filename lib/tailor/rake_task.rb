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
  # @example Use and override a configuration file
  #   Tailor::RakeTask.new do |task|
  #     task.config_file = 'hardcore_stylin.rb'
  #     task.file_set 'lib/**/*.rb' do |style|
  #       style.indentation_spaces 2, level: :warn
  #     end
  #   end
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
    def initialize(name = "tailor", desc = "Check style")
      @name, @desc = name, desc
      @tailor_opts = []
      @file_sets = []
      @recursive_file_sets = []

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

        begin
          failure = Tailor::CLI.run(@tailor_opts)
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
  end
end
