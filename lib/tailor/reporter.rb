class Tailor
  # Objects of this type are responsible for sending the right data to report
  # formatters.
  class Reporter
    attr_reader :formatters

    # For each in +formats+, it creates a new
    # +Tailor::Formatter::#{formatter.capitalize}+ object and adds it to
    # +@formatters+.
    #
    # @param [Array] formats A list of formatters to use for generating reports.
    def initialize(*formats)
      formats = %w(text) if formats.nil? || formats.empty?

      @formatters = formats.flatten.map do |formatter|
        retried = false

        begin
          Tailor::Formatters.const_get(formatter.capitalize).new
        rescue NameError
          require_relative "formatters/#{formatter}"

          if retried
            next
          else
            retried = true
            retry
          end
        end
      end.uniq

      @formatters.compact!
    end

    # Sends the data to each +@formatters+ to generate the report of problems
    # for the file that was just critiqued.  A problem is in the format:
    #
    #   { 'path/to/file.rb' => [Problem1, Problem2, etc.]}
    #
    # ...where Problem1 and Problem2 are of type {Tailor::Problem}.
    #
    # @param [Hash] file_problems
    # @param [Symbol,String] label The label of the file_set that defines the
    #   problems in +file_problems+.
    def file_report(file_problems, label)
      @formatters.each do |formatter|
        formatter.file_report(file_problems, label)
      end
    end

    # Sends the data to each +@formatters+ to generate the reports of problems
    # for all files that were just critiqued.
    #
    # @param [Hash] all_problems
    def summary_report(all_problems, opts={})
      @formatters.each do |formatter|
        summary = formatter.summary_report(all_problems)
        if formatter.respond_to?(:accepts_output_file) &&
          formatter.accepts_output_file &&
          !opts[:output_file].empty?
          File.open(opts[:output_file], 'w') { |f| f.puts summary }
        end
      end
    end
  end
end
