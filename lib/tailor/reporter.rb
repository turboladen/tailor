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
  end
end
