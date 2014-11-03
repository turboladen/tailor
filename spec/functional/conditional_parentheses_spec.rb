require 'spec_helper'
require_relative '../support/conditional_parentheses_cases'
require 'tailor/critic'
require 'tailor/configuration/style'

describe 'Conditional parentheses' do

  def file_name
    self.class.description
  end

  def contents
    CONDITIONAL_PARENTHESES[file_name] || begin
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

  context :no_parentheses do
    it 'does not warn' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are allowed' do
      style.allow_conditional_parentheses true, level: :warn
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are disabled' do
      style.allow_conditional_parentheses false, level: :off
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

  context :with_parentheses do
    it 'warns' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to eql [{
        type: 'conditional_parentheses',
        line: 1,
        column: 4,
        message: 'Parentheses around conditional expression at column 4.',
        level: :warn
      }]
    end

    it 'does not warn when parentheses are allowed' do
      style.allow_conditional_parentheses true, level: :warn
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are disabled' do
      style.allow_conditional_parentheses false, level: :off
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

  context :with_parentheses_no_space do
    it 'warns' do
      critic.check_file(file_name, style.to_hash)

      expect(critic.problems[file_name].select do |p|
        p[:type] == 'conditional_parentheses'
      end).to eql [{
        type: 'conditional_parentheses',
        line: 1,
        column: 3,
        message: 'Parentheses around conditional expression at column 3.',
        level: :warn
      }]
    end

    it 'does not warn when parentheses are allowed' do
      style.allow_conditional_parentheses true, level: :warn
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name].select do |p|
        p[:type] == 'conditional_parentheses'
      end).to be_empty
    end

    it 'does not warn when parentheses are disabled' do
      style.allow_conditional_parentheses false, level: :off
      critic.check_file(file_name, style.to_hash)

      expect(critic.problems[file_name].select do |p|
        p[:type] == 'conditional_parentheses'
      end).to be_empty
    end
  end

  context :method_call do
    it 'does not warn' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are allowed' do
      style.allow_conditional_parentheses true, level: :warn
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are disabled' do
      style.allow_conditional_parentheses false, level: :off
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

  context :indented_method_call do
    it 'does not warn' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are allowed' do
      style.allow_conditional_parentheses true, level: :warn
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are disabled' do
      style.allow_conditional_parentheses false, level: :off
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

  context :method_call_on_parens do
    it 'does not warn' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are allowed' do
      style.allow_conditional_parentheses true, level: :warn
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are disabled' do
      style.allow_conditional_parentheses false, level: :off
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

  context :double_parens do
    it 'warns by default' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to eql [{
        type: 'conditional_parentheses',
        line: 1,
        column: 4,
        message: 'Parentheses around conditional expression at column 4.',
        level: :warn
      }]
    end

    it 'does not warn when parentheses are allowed' do
      style.allow_conditional_parentheses true, level: :warn
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are disabled' do
      style.allow_conditional_parentheses false, level: :off
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

  context :unless_no_parentheses do
    it 'does not warn' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are allowed' do
      style.allow_conditional_parentheses true, level: :warn
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are disabled' do
      style.allow_conditional_parentheses false, level: :off
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

  context :unless_with_parentheses do
    it 'warns on parentheses' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to eql [{
        type: 'conditional_parentheses',
        line: 1,
        column: 8,
        message: 'Parentheses around conditional expression at column 8.',
        level: :warn
      }]
    end

    it 'does not warn when parentheses are allowed' do
      style.allow_conditional_parentheses true, level: :warn
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are disabled' do
      style.allow_conditional_parentheses false, level: :off
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

  context :case_no_parentheses do
    it 'does not warn' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are allowed' do
      style.allow_conditional_parentheses true, level: :warn
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are disabled' do
      style.allow_conditional_parentheses false, level: :off
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

  context :case_with_parentheses do
    it 'warns on parentheses' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to eql [{
        type: 'conditional_parentheses',
        line: 1,
        column: 6,
        message: 'Parentheses around conditional expression at column 6.',
        level: :warn
      }]
    end

    it 'does not warn when parentheses are allowed' do
      style.allow_conditional_parentheses true, level: :warn
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are disabled' do
      style.allow_conditional_parentheses false, level: :off
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

  context :while_no_parentheses do
    it 'does not warn' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are allowed' do
      style.allow_conditional_parentheses true, level: :warn
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are disabled' do
      style.allow_conditional_parentheses false, level: :off
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end

  context :while_with_parentheses do
    it 'warns on parentheses' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to eql [{
        type: 'conditional_parentheses',
        line: 1,
        column: 7,
        message: 'Parentheses around conditional expression at column 7.',
        level: :warn
      }]
    end

    it 'does not warn when parentheses are allowed' do
      style.allow_conditional_parentheses true, level: :warn
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end

    it 'does not warn when parentheses are disabled' do
      style.allow_conditional_parentheses false, level: :off
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems[file_name]).to be_empty
    end
  end
end
