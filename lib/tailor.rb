require 'log_switch'
require_relative 'tailor/base_methods'


class Tailor
  extend LogSwitch
  include Tailor::BaseMethods
end
