require 'spec_helper'
require_relative '../support/naming_cases'
require 'tailor/critic'
require 'tailor/configuration/style'


describe 'Naming problem detection' do
  before do
    allow(Tailor::Logger).to receive(:log)
    FakeFS.activate!
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  NAMING_OK.each do |file_name, contents|
    before do
      FileUtils.touch file_name
      File.open(file_name, 'w') { |f| f.write contents }
    end

    it 'is OK' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems).to eq(file_name =>  [])
    end
  end
end
