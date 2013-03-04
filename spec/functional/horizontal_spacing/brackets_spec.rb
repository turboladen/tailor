require_relative '../../spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'


BRACKETS = {}
BRACKETS['space_in_empty_array'] = %Q{[ ]}
BRACKETS['simple_array_space_after_lbracket'] = %Q{[ 1, 2, 3]}
BRACKETS['simple_array_space_before_rbracket'] = %Q{[1, 2, 3 ]}
BRACKETS['hash_key_ref_space_before_rbracket'] = %Q{thing[:one ]}
BRACKETS['hash_key_ref_space_after_lbracket'] = %Q{thing[ :one]}
BRACKETS['two_d_array_space_after_lbrackets'] =
  %Q{[ [1, 2, 3], [ 'a', 'b', 'c']]}
BRACKETS['two_d_array_space_before_rbrackets'] =
  %Q{[[1, 2, 3 ], [ 'a', 'b', 'c'] ]}


describe "Detection of spaces around brackets" do
  before do
    Tailor::Logger.stub(:log)
    FakeFS.activate!
    File.open(file_name, 'w') { |f| f.write contents }
    critic.check_file(file_name, style.to_hash)
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:contents) { BRACKETS[file_name]}

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  context "Arrays" do
    context "empty with space inside" do
      let(:file_name) { 'space_in_empty_array' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "spaces_after_lbracket" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "space after lbracket" do
      let(:file_name) { 'simple_array_space_after_lbracket' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "spaces_after_lbracket" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "space before rbracket" do
      let(:file_name) { 'simple_array_space_before_rbracket' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "spaces_before_rbracket" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 9 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end
  end

  context "Hash key references" do
    context "space before rbracket" do
      let(:file_name) { 'hash_key_ref_space_before_rbracket' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "spaces_before_rbracket" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 11 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "space after lbracket" do
      let(:file_name) { 'hash_key_ref_space_after_lbracket' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "spaces_after_lbracket" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 6 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end
  end
end
