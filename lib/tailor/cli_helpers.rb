require_relative 'version'

class Tailor
  module CLIHelpers

    # @return [String]
    def banner
      ruler + about + "\r\n" + usage + "\r\n"
    end

    # @return [String]
    def version
      ruler + about + "\r\n"
    end

    # @return [String]
    def ruler
      <<-RULER
  _________________________________________________________________________
  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
  |     |     |     |     |     |     |     |     |     |     |     |     |
  |           |           |           |           |           |           |
  |           1           2           3           4           5           |
  |                                                                       |
  -------------------------------------------------------------------------
      RULER
    end

    # @return [String]
    def about
      <<-ABOUT
  tailor (v#{Tailor::VERSION}).  \t\tA Ruby style checker.
\t\t\t\t\thttp://github.com/turboladen/tailor
      ABOUT
    end


    # @return [String]
    def usage
      <<-USEAGE
  Usage:
    $ #{File.basename($0)} [directory with .rb files]
      -OR-
    $ #{File.basename($0)} [single .rb file]"
      USEAGE
    end

    module_function :banner
    module_function :version
    module_function :about
    module_function :usage
    module_function :ruler
  end
end
