require 'rake'
require 'rake/tasklib'
require_relative 'critic'
require_relative 'configuration'
require_relative 'logger'
require_relative 'reporter'
require_relative 'cli/options'

begin
  # Support Rake > 0.8.7
  require 'rake/dsl_definition'
rescue LoadError
end

class Tailor
  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined? ::Rake::DSL

    attr_accessor :config_file
    attr_accessor :tailor_opts
    attr_accessor :formatters
    attr_accessor :file_sets

    # @param [String] name The task name.
    # @param [String] desc Description of the task.
    def initialize(name = "tailor", desc = "Check style")
      Tailor::Logger.log = false

      @name, @desc = name, desc
      @tailor_opts = []

      yield self if block_given?

      if config_file
        @tailor_opts.concat %W(--config-file=#{config_file})
      end

      @configuration = Tailor::Configuration.new([],
        Tailor::CLI::Options.parse!(tailor_opts))
      @configuration.formatters(formatters)
      @configuration.load!
      @reporter = Tailor::Reporter.new(@configuration.formatters)

      define_task
    end

    def define_task #:nodoc:
      desc @desc
      task @name do
        critic = Tailor::Critic.new

        critic.critique(@configuration.file_sets) do |problems_for_file, label|
          @reporter.file_report(problems_for_file, label)
        end

        @reporter.summary_report(critic.problems)

        critic.problem_count > 0
      end
    end
  end
end
