class Tailor

  # This is really just a base class for defining other Formatter types.
  class Formatter
    def initialize
      @pwd = Pathname(Dir.pwd)
    end

    # This method gets called by {Tailor::Reporter} after each file is
    # critiqued.  Redefine this to do what you want for that part of your
    # report.
    def file_report(file_problems, label)
      # Redefine this for your formatter...
    end

    # This method gets called by {Tailor::Reporter} after all files are
    # critiqued.  Redefine this to do what you want for that part of your
    # report.
    def summary_report(all_problems)
      # Redefine this for your formatter...
    end

    # @param [Hash<Array>] problems
    # @param [Symbol] level The level of problem to find.
    # @return [Array] Problem list at the given level.
    def problems_at_level(problems, level)
      problems.values.flatten.find_all { |v| v[:level] == level }
    end

    # Gets a list of all types of problems included in the problem set.
    #
    # @param [Array] problems
    # @return [Array<Symbol>] The list of problem types.
    def problem_levels(problems)
      problems.values.flatten.collect { |v| v[:level] }.uniq
    end
  end
end
