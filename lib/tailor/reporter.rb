class Tailor
  class Reporter
    attr_reader :formatters

    def initialize(*formats)
      @formatters = []

      formats.flatten.each do |formatter|
        require_relative "formatters/#{formatter}"
        @formatters << eval("Tailor::Formatter::#{formatter.capitalize}.new")
      end
    end
    
    def file_report(file_problems, label)
      @formatters.each do |formatter|
        formatter.file_report(file_problems, label)
      end
    end
    
    def summary_report(all_problems)
      @formatters.each do |formatter|
        formatter.summary_report(all_problems)
      end
    end
  end
end
