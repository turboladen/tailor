require 'spec_helper'
require_relative '../support/string_interpolation_cases'
require 'tailor/critic'
require 'tailor/configuration/style'

describe 'String interpolation cases' do
  def file_name
    self.class.description
  end

  def contents
    INTERPOLATION[file_name] || begin
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
    style.allow_unnecessary_double_quotes true, level: :off

    style
  end

  context :one_variable_interpolated_only do
    it 'warns when interpolation is used unnecessarily' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to eql [{
        type: 'unnecessary_string_interpolation',
        line: 1,
        column: 6,
        message: 'Variable interpolated unnecessarily',
        level: :warn
      }]
    end
  end

  context :mixed_content_and_expression do
    it 'does not warn' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

  context :no_string do
    it 'does not warn' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

  context :two_variables do
    it 'does not warn' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

  context :two_strings_with_unnecessary_interpolation do
    it 'warns against both strings' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to eql [
        {
          type: 'unnecessary_string_interpolation',
          line: 1,
          column: 6,
          message: 'Variable interpolated unnecessarily',
          level: :warn
        },
        {
          type: 'unnecessary_string_interpolation',
          line: 1,
          column: 17,
          message: 'Variable interpolated unnecessarily',
          level: :warn
        }
      ]
    end
  end

  context :multiline_string_with_unnecessary_interpolation do
    it 'warns against the first line' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to eql [{
        type: 'unnecessary_string_interpolation',
        line: 1,
        column: 6,
        message: 'Variable interpolated unnecessarily',
        level: :warn
      }]
    end
  end

  context :multiline_word_list do
    it 'does not warn' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

  context :nested_interpolation do
    it 'does not warn' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end
end
