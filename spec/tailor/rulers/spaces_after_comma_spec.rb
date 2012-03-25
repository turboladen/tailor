require_relative '../../spec_helper'
require 'tailor/rulers/spaces_after_comma_ruler'

describe Tailor::Rulers::SpacesAfterCommaRuler do
  describe "#comma_update" do
    it "does" do
      subject.comma_update([], "1234", 1, 4)
    end
  end
end
