require_relative 'tailor/configuration'

class Tailor
  def self.config
    configuration = Tailor::Configuration.new
    yield configuration if block_given?

    configuration
  end
end
