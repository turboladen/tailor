require_relative '../spec_helper'
require 'tailor'

describe Tailor do
  before { Tailor::Logger.log = false }

  describe "::config" do
    it "creates a new Configuration object" do
      Tailor::Configuration.should_receive(:new)
      Tailor.config
    end

    it "returns a Configuration object" do
      Tailor.config.should be_a Tailor::Configuration
    end
  end
end
