require 'spec_helper'
require 'tailor'

describe Tailor do
  before { Tailor::Logger.log = false }

  describe '.config' do
    it 'creates a new Configuration object' do
      expect(Tailor::Configuration).to receive(:new)
      Tailor.config
    end

    it 'returns a Configuration object' do
      expect(Tailor.config).to be_a Tailor::Configuration
    end
  end
end
