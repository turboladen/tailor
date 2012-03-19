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
      @configuration = Configuration.new(args.last, options)

      if options[:show_config]
        @configuration.show
        exit
      end

      @critic = Critic.new(@configuration.style)
      @reporter = Reporter.new(@configuration.formatters)
    end

    # This checks all of the files detected during the configuration gathering
    # process, then hands results over to the {Reporter} to be reported.
    #
    # @return [Boolean] +true+ if no problems were detected; false if there
    #   were.
    def execute!
      @configuration.file_list.each do |file|
        problems = @critic.check_file(file)

        @reporter.formatters.each do |formatter|
          formatter.print_file_report(problems)
        end
      end

      @reporter.formatters.each do |formatter|
        formatter.print_summary_report(@critic.problems)
      end

      @critic.problem_count > 0
    end
  end
end
