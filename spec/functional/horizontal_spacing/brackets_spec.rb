require 'spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'

BRACKETS = {}
BRACKETS['space_in_empty_array'] = %([ ])
BRACKETS['simple_array_space_after_lbracket'] = %([ 1, 2, 3])
BRACKETS['simple_array_space_before_rbracket'] = %([1, 2, 3 ])
BRACKETS['hash_key_ref_space_before_rbracket'] = %(thing[:one ])
BRACKETS['hash_key_ref_space_after_lbracket'] = %(thing[ :one])
BRACKETS['two_d_array_space_after_lbrackets'] =
  %([ [1, 2, 3], [ 'a', 'b', 'c']])
BRACKETS['two_d_array_space_before_rbrackets'] =
  %([[1, 2, 3 ], [ 'a', 'b', 'c'] ])

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

  let(:contents) { BRACKETS[file_name] }

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  context 'Arrays' do
    context 'empty with space inside' do
      let(:file_name) { 'space_in_empty_array' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_after_lbracket' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'space after lbracket' do
      let(:file_name) { 'simple_array_space_after_lbracket' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_after_lbracket' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'space before rbracket' do
      let(:file_name) { 'simple_array_space_before_rbracket' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_before_rbracket' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 9 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end
  end

  context 'Hash key references' do
    context 'space before rbracket' do
      let(:file_name) { 'hash_key_ref_space_before_rbracket' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_before_rbracket' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 11 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'space after lbracket' do
      let(:file_name) { 'hash_key_ref_space_after_lbracket' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_after_lbracket' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 6 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end
  end
end
