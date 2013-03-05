require_relative 'configuration'
require_relative 'critic'
require_relative 'cli/options'
require_relative 'logger'
require_relative 'reporter'

class Tailor

  # The Command-Line Interface worker.  Execution from the command line
  # comes through here.
  class CLI
    include LogSwitch::Mixin

    # The main method of execution from the command line.
    #
    # @param [Array] args Arguments from the command-line.
    # @param [Tailor::Configuration] configuration An optional Configuration to
    #   override loading one from config files.  Useful for RakeTask.
    def self.run(args, configuration=nil)
      new(args, configuration).execute!
    end

    # @param [Array] args Arguments from the command-line.
    # @param [Tailor::Configuration] configuration An optional Configuration to
    #   override loading one from config files.  Useful for RakeTask.
    def initialize(args, configuration=nil)
      options = Options.parse!(args)

      if configuration.nil?
        @configuration = Configuration.new(args, options)
        @configuration.load!
      else
        log "<#{self.class}> Configuration passed in: #{configuration.inspect}"
        @configuration = configuration
      end

      if options.show_config
        @configuration.show
        exit
      end

      @critic = Critic.new
      @reporter = Reporter.new(@configuration.formatters)
    end

    # This checks all of the files detected during the configuration gathering
    # process, then hands results over to the {Tailor::Reporter} to be reported.
    #
    # @return [Boolean] +true+ if no problems were detected; false if there
    #   were.
    def execute!
      @critic.critique(@configuration.file_sets) do |problems_for_file, label|
        @reporter.file_report(problems_for_file, label)
      end

      @reporter.summary_report(@critic.problems, output_file: @configuration.output_file)
      @critic.problem_count(:error) > 0
    end

    # @todo Remove; doesn't get used anywhere.
    def result
      @critic.critique(@configuration.file_sets)
      @critic.problems
    end
  end
end
