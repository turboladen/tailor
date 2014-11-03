require 'spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'

BRACES = {}
BRACES['single_line_hash_0_spaces_before_lbrace'] =
  %(thing ={ :one => 'one' })

BRACES['single_line_hash_2_spaces_before_lbrace'] =
  %(thing =  { :one => 'one' })

BRACES['single_line_hash_2_spaces_before_rbrace'] =
  %(thing = { :one => 'one'  })

BRACES['single_line_hash_2_spaces_after_lbrace'] =
  %(thing = {  :one => 'one' })

BRACES['two_line_hash_2_spaces_before_lbrace'] = %(thing1 =
  thing2 =  { :one => 'one' })

BRACES['two_line_hash_2_spaces_before_rbrace'] = %(thing1 =
  thing2 = { :one => 'one'  })

BRACES['two_line_hash_2_spaces_before_lbrace_lonely_braces'] =
  %(thing1 =
  thing2 =  {
    :one => 'one'
  })

BRACES['space_in_empty_hash_in_string_in_block'] =
  %([1].map { |n| { :first => "\#{n}-\#{{ }}" } })

BRACES['single_line_block_2_spaces_before_lbrace'] =
  %(1..10.times  { |n| puts n })

BRACES['single_line_block_in_string_interp_2_spaces_before_lbrace'] =
  %("I did this \#{1..10.times  { |n| puts n }} times.")

BRACES['single_line_block_0_spaces_before_lbrace'] =
  %(1..10.times{ |n| puts n })

BRACES['two_line_braces_block_2_spaces_before_lbrace'] =
  %(1..10.times  { |n|
  puts n})

BRACES['two_line_braces_block_0_spaces_before_lbrace_trailing_comment'] =
  %(1..10.times{ |n|    # comment
  puts n})

BRACES['no_space_after_l_before_r_after_string_interp'] =
  %(logger.debug "from \#{current} to \#{new_ver}", {:format => :short})

BRACES['no_space_before_consecutive_rbraces'] =
  %(thing = { 'id' => "\#{source}", 'attributes' => { 'height' => "\#{height}"}})

describe 'Detection of spacing around braces' do
  before do
    allow(Tailor::Logger).to receive(:log)
    FakeFS.activate!
    File.open(file_name, 'w') { |f| f.write contents }
    critic.check_file(file_name, style.to_hash)
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:contents) { BRACES[file_name] }

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  context 'single-line Hash' do
    context '0 spaces before lbrace' do
      let!(:file_name) { 'single_line_hash_0_spaces_before_lbrace' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_before_lbrace' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 7 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context '2 spaces before lbrace' do
      let!(:file_name) { 'single_line_hash_2_spaces_before_lbrace' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_before_lbrace' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 9 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context '2 spaces after lbrace' do
      let!(:file_name) { 'single_line_hash_2_spaces_after_lbrace' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_after_lbrace' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 9 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context '2 spaces before rbrace' do
      let!(:file_name) { 'single_line_hash_2_spaces_before_rbrace' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_before_rbrace' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 25 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end
  end

  context 'two-line Hash' do
    context '2 spaces before lbrace' do
      let!(:file_name) { 'two_line_hash_2_spaces_before_lbrace' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_before_lbrace' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 12 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context '2 spaces before rbrace' do
      let!(:file_name) { 'two_line_hash_2_spaces_before_rbrace' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_before_rbrace' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 28 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context '2 spaces before lbrace, lonely braces' do
      let!(:file_name) { 'two_line_hash_2_spaces_before_lbrace_lonely_braces' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_before_lbrace' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 12 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end
  end

  context 'single-line block' do
    context 'space in empty Hash' do
      let!(:file_name) { 'space_in_empty_hash_in_string_in_block' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_in_empty_braces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 36 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context '0 spaces before lbrace' do
      let!(:file_name) { 'single_line_block_0_spaces_before_lbrace' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_before_lbrace' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 11 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context '2 spaces before lbrace' do
      let!(:file_name) { 'single_line_block_2_spaces_before_lbrace' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_before_lbrace' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 13 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'in String interpolation, 2 spaces before lbrace' do
      let!(:file_name) { 'single_line_block_in_string_interp_2_spaces_before_lbrace' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_before_lbrace' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 27 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end
  end

  context 'multi-line block' do
    context '2 spaces before lbrace' do
      let!(:file_name) { 'two_line_braces_block_2_spaces_before_lbrace' }
      specify { expect(critic.problems[file_name].size).to eq 2 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_before_lbrace' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 13 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
      specify { expect(critic.problems[file_name].last[:type]).to eq 'spaces_before_rbrace' }
      specify { expect(critic.problems[file_name].last[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].last[:column]).to eq 8 }
      specify { expect(critic.problems[file_name].last[:level]).to eq :error }
    end

    context '0 spaces before lbrace, with trailing comment' do
      let!(:file_name) { 'two_line_braces_block_0_spaces_before_lbrace_trailing_comment' }
      specify { expect(critic.problems[file_name].size).to eq 2 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_before_lbrace' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 11 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
      specify { expect(critic.problems[file_name].last[:type]).to eq 'spaces_before_rbrace' }
      specify { expect(critic.problems[file_name].last[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].last[:column]).to eq 8 }
      specify { expect(critic.problems[file_name].last[:level]).to eq :error }
    end
  end

  context 'String interpolation' do
    context '0 spaces after lbrace or before rbrace' do
      let!(:file_name) { 'no_space_after_l_before_r_after_string_interp' }
      specify { expect(critic.problems[file_name].size).to eq 2 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'spaces_after_lbrace' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 47 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
      specify { expect(critic.problems[file_name].last[:type]).to eq 'spaces_before_rbrace' }
      specify { expect(critic.problems[file_name].last[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].last[:column]).to eq 64 }
      specify { expect(critic.problems[file_name].last[:level]).to eq :error }
    end

    context 'no space before consecutive rbraces' do
      let(:file_name) { 'no_space_before_consecutive_rbraces' }
      let(:problems) { critic.problems[file_name].select { |p| p[:type] == 'spaces_before_rbrace' } }
      specify { expect(problems.size).to eq 2 }
      specify { expect(problems.first[:type]).to eq 'spaces_before_rbrace' }
      specify { expect(problems.first[:line]).to eq 1 }
      specify { expect(problems.first[:column]).to eq 72 }
      specify { expect(problems.first[:level]).to eq :error }
      specify { expect(problems.last[:type]).to eq 'spaces_before_rbrace' }
      specify { expect(problems.last[:line]).to eq 1 }
      specify { expect(problems.last[:column]).to eq 73 }
      specify { expect(problems.last[:level]).to eq :error }
    end
  end
end
