require 'spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'

PARENS = {}
PARENS['simple_method_call_space_after_lparen'] = %(thing( one, two))
PARENS['simple_method_call_space_before_rparen'] = %(thing(one, two ))
PARENS['method_call_space_after_lparen_trailing_comment'] =
  %(thing( one, two)    # comment)
PARENS['method_call_space_after_lparen_before_rparen_trailing_comment'] =
  %(thing( one, two )    # comment)

PARENS['multi_line_method_call_space_after_lparen'] = %(thing( one,
  two))
PARENS['multi_line_method_call_space_after_lparen_trailing_comment'] =
  %(thing( one,
  two))

describe 'Detection of spaces around brackets' do
  before do
    allow(Tailor::Logger).to receive(:log)
    FakeFS.activate!
    File.open(file_name, 'w') { |f| f.write contents }
    critic.check_file(file_name, style.to_hash)
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:contents) { PARENS[file_name] }

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  context 'methods' do
    context 'space after lparen' do
      let(:file_name) { 'simple_method_call_space_after_lparen' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_after_lparen' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 6 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'space before rparen' do
      let(:file_name) { 'simple_method_call_space_before_rparen' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_before_rparen' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 15 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'space after lparen, trailing comment' do
      let(:file_name) { 'method_call_space_after_lparen_trailing_comment' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_after_lparen' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 6 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'space after lparen, before rparen, trailing comment' do
      let(:file_name) { 'method_call_space_after_lparen_before_rparen_trailing_comment' }
      specify { expect(critic.problems[file_name].size).to eq 2 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_after_lparen' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 6 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
      specify { expect(critic.problems[file_name].last[:type]).to eq 'spaces_before_rparen' }
      specify { expect(critic.problems[file_name].last[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].last[:column]).to eq 16 }
      specify { expect(critic.problems[file_name].last[:level]).to eq :error }
    end
  end

  context 'multi-line method calls' do
    context 'space after lparen' do
      let(:file_name) { 'multi_line_method_call_space_after_lparen' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_after_lparen' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 6 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'space after lparen, trailing comment' do
      let(:file_name) { 'multi_line_method_call_space_after_lparen_trailing_comment' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_after_lparen' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 6 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end
  end
end
