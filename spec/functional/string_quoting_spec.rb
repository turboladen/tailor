require 'spec_helper'
require_relative '../support/string_quoting_cases'
require 'tailor/critic'
require 'tailor/configuration/style'

describe 'String Quoting' do

  def file_name
    self.class.description
  end

  def contents
    QUOTING[file_name] || begin
      raise "Example not found: #{file_name}"
    end
  end

  before do
    allow(Tailor::Logger).to receive(:log)
    FakeFS.activate!
    FileUtils.touch file_name
    File.open(file_name, 'w') { |f| f.write contents }
  end

  let(:critic) { Tailor::Critic.new }

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off
    style
  end

  context :single_quotes_no_interpolation do
    it 'does not warn' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

  context :double_quotes_with_interpolation do
    it 'does not warn' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

  context :double_quotes_no_interpolation do
    it 'warns that double quotes are unnecessary' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to eql [{
        type: 'unnecessary_double_quotes',
        line: 1,
        column: 6,
        message: 'Unnecessary double quotes at column 6, expected single quotes.',
        level: :warn
      }]
    end
  end

  context :double_quotes_no_interpolation_twice do
    it 'warns that double quotes are unnecessary' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to eql [
        {
          type: 'unnecessary_double_quotes',
          line: 1,
          column: 6,
          message: 'Unnecessary double quotes at column 6, expected single quotes.',
          level: :warn
        },
        {
          type: 'unnecessary_double_quotes',
          line: 1,
          column: 14,
          message: 'Unnecessary double quotes at column 14, expected single quotes.',
          level: :warn
        }
      ]
    end
  end

  context :nested_quotes do
    it 'does not warn' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

  context :escape_sequence do
    it 'does not warn when a double quoted string contains a newline' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

end
