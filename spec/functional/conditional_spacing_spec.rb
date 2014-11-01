require 'spec_helper'
require_relative '../support/conditional_spacing_cases'
require 'tailor/critic'
require 'tailor/configuration/style'

describe 'Conditional spacing' do

  def file_name
    self.class.description
  end

  def contents
    CONDITIONAL_SPACING[file_name] || begin
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

  context :no_space_after_if do
    it 'warns when there is no space after an if statement' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name].reject do |p|
        p[:type] == 'conditional_parentheses'
      end).to eql [{
        type: 'spaces_after_conditional',
        line: 1,
        column: 0,
        message: '0 spaces after conditional at column 0, expected 1.',
        level: :error
      }]
    end

    it 'warns with the correct number of expected spaces' do
      style.spaces_after_conditional 2, level: :error
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name].reject do |p|
        p[:type] == 'conditional_parentheses'
      end).to eql [{
        type: 'spaces_after_conditional',
        line: 1,
        column: 0,
        message: '0 spaces after conditional at column 0, expected 2.',
        level: :error
      }]
    end

    it 'does not warn if spaces are set to zero' do
      style.spaces_after_conditional 0, level: :error
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name].reject do |p|
        p[:type] == 'conditional_parentheses'
      end).to be_empty
    end

    it 'does not warn if spaces are disabled' do
      style.spaces_after_conditional 2, level: :off
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name].reject do |p|
        p[:type] == 'conditional_parentheses'
      end).to be_empty
    end
  end

  context :space_after_if do
    it 'does not warn when there is a space after the if' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name].reject do |p|
        p[:type] == 'conditional_parentheses'
      end).to be_empty
    end

    it 'warns if spaces has been set to zero' do
      style.spaces_after_conditional 0, level: :error
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name].reject do |p|
        p[:type] == 'conditional_parentheses'
      end).to eql [{
        type: 'spaces_after_conditional',
        line: 1,
        column: 0,
        message: '1 spaces after conditional at column 0, expected 0.',
        level: :error
      }]
    end
  end

  context :no_parens do
    it 'never warns' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name].reject do |p|
        p[:type] == 'conditional_parentheses'
      end).to be_empty
    end
  end

  context :nested_parens do
    it 'warns when there is no space after an if statement' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name].reject do |p|
        p[:type] == 'conditional_parentheses'
      end).to eql [{
        type: 'spaces_after_conditional',
        line: 1,
        column: 0,
        message: '0 spaces after conditional at column 0, expected 1.',
        level: :error
      }]
    end
  end

  context :no_space_after_unless do
    it 'warns when there is no space after an unless statement' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name].reject do |p|
        p[:type] == 'conditional_parentheses'
      end).to eql [{
        type: 'spaces_after_conditional',
        line: 1,
        column: 0,
        message: '0 spaces after conditional at column 0, expected 1.',
        level: :error
      }]
    end
  end

  context :space_after_unless do
    it 'does not warn when there is space after an unless statement' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name].reject do |p|
        p[:type] == 'conditional_parentheses'
      end).to be_empty
    end
  end

  context :no_space_after_case do
    it 'warns when there is no space after a case statement' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name].reject do |p|
        p[:type] == 'conditional_parentheses'
      end).to eql [{
        type: 'spaces_after_conditional',
        line: 1,
        column: 5,
        message: '0 spaces after conditional at column 5, expected 1.',
        level: :error
      }]
    end
  end

  context :space_after_case do
    it 'does not warn when there is space after a case statement' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name].reject do |p|
        p[:type] == 'conditional_parentheses'
      end).to be_empty
    end
  end
end
