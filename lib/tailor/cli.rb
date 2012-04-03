require_relative 'configuration'
require_relative 'critic'
require_relative 'cli/options'
require_relative 'logger'
require_relative 'reporter'

class Tailor

  # The Command-Line Interface worker.  Execution from the command line should
  # come through here.
  class CLI
    include LogSwitch::Mixin

    # The main method of execution from the command line.
    def self.run(args)
      new(args).execute!
    end

    def initialize(args)
      Tailor::Logger.log = false
      options = Options.parse!(args)
      
      @configuration = Configuration.new(args, options)
      @configuration.load!

      if options.show_config
        @configuration.show
      end

      @critic = Critic.new(@configuration.file_sets)
      @reporter = Reporter.new(@configuration.formatters)
    end

    # This checks all of the files detected during the configuration gathering
    # process, then hands results over to the {Reporter} to be reported.
    #
    # @return [Boolean] +true+ if no problems were detected; false if there
    #   were.
    def execute!
      @critic.critique do |problems_for_file, label|
        @reporter.file_report(problems_for_file, label)
      end

      @reporter.summary_report(@critic.problems)
      
      @critic.problem_count > 0
    end
  end
end
