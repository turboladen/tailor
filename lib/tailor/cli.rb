require_relative 'configuration'
require_relative 'critic'
require_relative 'cli/options'
require_relative 'logger'
require_relative 'reporter'
require 'awesome_print'

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
      #raise unless checkable?(glob)
      
      @configuration = Configuration.new(args, options)
      ap @configuration

      if options.show_config
        @configuration.show
        exit
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
=begin
      @configuration.file_list.each do |file|
        problems = @critic.check_file(file)

        @reporter.formatters.each do |formatter|
          formatter.print_file_report(problems)
        end
      end
=end
      @critic.critique do |problems_for_file|
        @reporter.file_report problems_for_file
      end

=begin
      @reporter.formatters.each do |formatter|
        formatter.print_summary_report(@critic.problems)
      end
=end
      @reporter.summary_report(@critic.problems)

      @critic.problem_count > 0
    end
    
    # Checks to see if +path_to_check+ is a real file or directory.
    #
    # @param [String] path_to_check
    # @return [Boolean]
    def checkable? path_to_check
      File.file?(path_to_check) || File.directory?(path_to_check)
    end
  end
end
