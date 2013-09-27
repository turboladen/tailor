class String
  # Borrowed from ActiveSupport, this converts camel-case Strings to
  # snake-case.
  #
  # @return [String]
  def underscore
    self.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
      gsub(/([a-z\d])([A-Z])/, '\1_\2').
      tr('-', '_').
      downcase
  end
end
