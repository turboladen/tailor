require_relative '../../spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'

BRACES = {}
BRACES['single_line_hash_0_spaces_before_lbrace'] =
  %Q{thing ={ :one => 'one' }}

BRACES['single_line_hash_2_spaces_before_lbrace'] =
  %Q{thing =  { :one => 'one' }}

BRACES['single_line_hash_2_spaces_before_rbrace'] =
  %Q{thing = { :one => 'one'  }}

BRACES['single_line_hash_2_spaces_after_lbrace'] =
  %Q{thing = {  :one => 'one' }}

BRACES['two_line_hash_2_spaces_before_lbrace'] = %Q{thing1 =
  thing2 =  { :one => 'one' }}

BRACES['two_line_hash_2_spaces_before_rbrace'] = %Q{thing1 =
  thing2 = { :one => 'one'  }}

BRACES['two_line_hash_2_spaces_before_lbrace_lonely_braces'] =
  %Q{thing1 =
  thing2 =  {
    :one => 'one'
  }}

BRACES['space_in_empty_hash_in_string_in_block'] =
  %Q{[1].map { |n| { :first => "\#{n}-\#{{ }}" } }}

BRACES['single_line_block_2_spaces_before_lbrace'] =
  %Q{1..10.times  { |n| puts n }}

BRACES['single_line_block_in_string_interp_2_spaces_before_lbrace'] =
  %Q{"I did this \#{1..10.times  { |n| puts n }} times."}

BRACES['single_line_block_0_spaces_before_lbrace'] =
  %Q{1..10.times{ |n| puts n }}

BRACES['two_line_braces_block_2_spaces_before_lbrace'] =
  %Q{1..10.times  { |n|
  puts n}}

BRACES['two_line_braces_block_0_spaces_before_lbrace_trailing_comment'] =
  %Q{1..10.times{ |n|    # comment
  puts n}}

BRACES['no_space_after_l_before_r_after_string_interp'] =
  %Q{logger.debug "from \#{current} to \#{new_ver}", {:format => :short}}

BRACES['no_space_before_consecutive_rbraces'] =
  %Q{thing = { 'id' => "\#{source}", 'attributes' => { 'height' => "\#{height}"}}}

describe "Detection of spacing around braces" do
  before do
    Tailor::Logger.stub(:log)
    FakeFS.activate!
    File.open(file_name, 'w') { |f| f.write contents }
    critic.check_file(file_name, style.to_hash)
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:contents) { BRACES[file_name]}

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  context "single-line Hash" do
    context "0 spaces before lbrace" do
      let!(:file_name) { 'single_line_hash_0_spaces_before_lbrace' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "spaces_before_lbrace" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 7 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "2 spaces before lbrace" do
      let!(:file_name) { 'single_line_hash_2_spaces_before_lbrace' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "spaces_before_lbrace" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 9 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "2 spaces after lbrace" do
      let!(:file_name) { 'single_line_hash_2_spaces_after_lbrace' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "spaces_after_lbrace" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 9 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "2 spaces before rbrace" do
      let!(:file_name) { 'single_line_hash_2_spaces_before_rbrace' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "spaces_before_rbrace" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 25 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end
  end

  context "two-line Hash" do
    context "2 spaces before lbrace" do
      let!(:file_name) { 'two_line_hash_2_spaces_before_lbrace' }
      specify { critic.problems[file_name.to_s].size.should be 1 }
      specify { critic.problems[file_name.to_s].first[:type].should == "spaces_before_lbrace" }
      specify { critic.problems[file_name.to_s].first[:line].should be 2 }
      specify { critic.problems[file_name.to_s].first[:column].should be 12 }
      specify { critic.problems[file_name.to_s].first[:level].should be :error }
    end

    context "2 spaces before rbrace" do
      let!(:file_name) { 'two_line_hash_2_spaces_before_rbrace' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "spaces_before_rbrace" }
      specify { critic.problems[file_name].first[:line].should be 2 }
      specify { critic.problems[file_name].first[:column].should be 28 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "2 spaces before lbrace, lonely braces" do
      let!(:file_name) { 'two_line_hash_2_spaces_before_lbrace_lonely_braces' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "spaces_before_lbrace" }
      specify { critic.problems[file_name].first[:line].should be 2 }
      specify { critic.problems[file_name].first[:column].should be 12 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end
  end

  context "single-line block" do
    context "space in empty Hash" do
      let!(:file_name) { 'space_in_empty_hash_in_string_in_block' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "spaces_in_empty_braces" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 36 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "0 spaces before lbrace" do
      let!(:file_name) { 'single_line_block_0_spaces_before_lbrace' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "spaces_before_lbrace" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 11 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "2 spaces before lbrace" do
      let!(:file_name) { 'single_line_block_2_spaces_before_lbrace' }
      specify { critic.problems[file_name.to_s].size.should be 1 }
      specify { critic.problems[file_name.to_s].first[:type].should == "spaces_before_lbrace" }
      specify { critic.problems[file_name.to_s].first[:line].should be 1 }
      specify { critic.problems[file_name.to_s].first[:column].should be 13 }
      specify { critic.problems[file_name.to_s].first[:level].should be :error }
    end

    context "in String interpolation, 2 spaces before lbrace" do
      let!(:file_name) { 'single_line_block_in_string_interp_2_spaces_before_lbrace' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "spaces_before_lbrace" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 27 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end
  end

  context "multi-line block" do
    context "2 spaces before lbrace" do
      let!(:file_name) { 'two_line_braces_block_2_spaces_before_lbrace' }
      specify { critic.problems[file_name].size.should be 2 }
      specify { critic.problems[file_name].first[:type].should == "spaces_before_lbrace" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 13 }
      specify { critic.problems[file_name].first[:level].should be :error }
      specify { critic.problems[file_name].last[:type].should == "spaces_before_rbrace" }
      specify { critic.problems[file_name].last[:line].should be 2 }
      specify { critic.problems[file_name].last[:column].should be 8 }
      specify { critic.problems[file_name].last[:level].should be :error }
    end

    context "0 spaces before lbrace, with trailing comment" do
      let!(:file_name) { 'two_line_braces_block_0_spaces_before_lbrace_trailing_comment' }
      specify { critic.problems[file_name].size.should be 2 }
      specify { critic.problems[file_name].first[:type].should == "spaces_before_lbrace" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 11 }
      specify { critic.problems[file_name].first[:level].should be :error }
      specify { critic.problems[file_name].last[:type].should == "spaces_before_rbrace" }
      specify { critic.problems[file_name].last[:line].should be 2 }
      specify { critic.problems[file_name].last[:column].should be 8 }
      specify { critic.problems[file_name].last[:level].should be :error }
    end
  end

  context "String interpolation" do
    context "0 spaces after lbrace or before rbrace" do
      let!(:file_name) { 'no_space_after_l_before_r_after_string_interp' }
      specify { critic.problems[file_name].size.should be 2 }
      specify { critic.problems[file_name].first[:type].should == "spaces_after_lbrace" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 47 }
      specify { critic.problems[file_name].first[:level].should be :error }
      specify { critic.problems[file_name].last[:type].should == "spaces_before_rbrace" }
      specify { critic.problems[file_name].last[:line].should be 1 }
      specify { critic.problems[file_name].last[:column].should be 64 }
      specify { critic.problems[file_name].last[:level].should be :error }
    end

    context "no space before consecutive rbraces" do
      let(:file_name) { 'no_space_before_consecutive_rbraces' }
      specify { critic.problems[file_name].size.should be 2 }
      specify { critic.problems[file_name].first[:type].should == "spaces_before_rbrace" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 72 }
      specify { critic.problems[file_name].first[:level].should be :error }
      specify { critic.problems[file_name].last[:type].should == "spaces_before_rbrace" }
      specify { critic.problems[file_name].last[:line].should be 1 }
      specify { critic.problems[file_name].last[:column].should be 73 }
      specify { critic.problems[file_name].last[:level].should be :error }
    end
  end
end
