require 'spec_helper'
require_relative '../../support/line_indentation_cases'
require 'tailor/critic'
require 'tailor/configuration/style'

describe 'Line continuation indentation' do
  def file_name
    self.class.description
  end

  def contents
    LINE_INDENT[file_name] || begin
      raise "Example not found: #{file_name}"
    end
  end

  before do
    Tailor::Logger.stub(:log)
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

  context :line_continues_further_indented do

    it 'warns when line continuation spacing is not specified' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to eql [{
        type: 'indentation_spaces',
        line: 2,
        column: 4,
        message: "Line is indented to column 4, but should be at 2.",
        level: :error
      }]
    end

    it 'warns when line continuation spacing is disabled' do
      style.indentation_spaces 2, level: :error, line_continuations: :off
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to eql [{
        type: 'indentation_spaces',
        line: 2,
        column: 4,
        message: "Line is indented to column 4, but should be at 2.",
        level: :error
      }]
    end

    it 'does not warn when line continuation spacing is enabled' do
      style.indentation_spaces 2, level: :error, line_continuations: true
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

  end

  context :line_continues_at_same_indentation do

    it 'does not warn when line continuation spacing is not specified' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when line continuation spacing is disabled' do
      style.indentation_spaces 2, level: :error, line_continuations: :off
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'warns when line continuation spacing is enabled' do
      style.indentation_spaces 2, level: :error, line_continuations: true
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to eql [{
        type: 'indentation_spaces',
        line: 2,
        column: 2,
        message: "Line is indented to column 2, but should be at 4.",
        level: :error
      }]
    end

  end

  context :parameters_continuation_indent_across_lines do
    it 'warns when line continuation spacing is not specified' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to eql [{
        type: 'indentation_spaces',
        line: 2,
        column: 4,
        message: "Line is indented to column 4, but should be at 2.",
        level: :error
      }]
    end

    it 'warns when line continuation spacing is disabled' do
      style.indentation_spaces 2, level: :error, line_continuations: :off
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to eql [{
        type: 'indentation_spaces',
        line: 2,
        column: 4,
        message: "Line is indented to column 4, but should be at 2.",
        level: :error
      }]
    end

    it 'warns when line continuation spacing is enabled' do
      style.indentation_spaces 2, level: :error, line_continuations: true
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

  end

  context :parameters_no_continuation_indent_across_lines do
    it 'warns when line continuation spacing is not specified' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'warns when line continuation spacing is disabled' do
      style.indentation_spaces 2, level: :error, line_continuations: :off
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'warns when line continuation spacing is enabled' do
      style.indentation_spaces 2, level: :error, line_continuations: true
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to eql [{
        type: 'indentation_spaces',
        line: 2,
        column: 2,
        message: "Line is indented to column 2, but should be at 4.",
        level: :error
      }]
    end

  end

  [
    :hash_spans_lines,
    :if_else,
    :line_continues_without_nested_statements,
    :minitest_test_cases,
    :nested_blocks,
    :one_assignment_per_line
  ].each do |never_warns_example|
      context never_warns_example do

        it 'does not warn when line continuation spacing is not specified' do
          critic.check_file(file_name, style.to_hash)
          expect(critic.problems[file_name]).to be_empty
        end

        it 'does not warn when line continuation spacing is disabled' do
          style.indentation_spaces 2, level: :error, line_continuations: :off
          critic.check_file(file_name, style.to_hash)
          expect(critic.problems[file_name]).to be_empty
        end

        it 'does not warn when line continuation spacing is enabled' do
          style.indentation_spaces 2, level: :error, line_continuations: true
          critic.check_file(file_name, style.to_hash)
          expect(critic.problems[file_name]).to be_empty
        end
      end
    end
end
