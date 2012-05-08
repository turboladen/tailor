require_relative '../../spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'


LONG_LINE = {}
LONG_LINE[:long_line_no_newline] = %Q{'#{'#' * 79}'}
LONG_LINE[:long_line_newline_at_82] = %Q{'#{'#' * 79}'
}


describe "Long line detection" do
  before do
    Tailor::Logger.stub(:log)
    FakeFS.activate!
    File.open(file_name.to_s, 'w') { |f| f.write contents }
    critic.check_file(file_name.to_s, style.to_hash)
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:contents) { LONG_LINE[file_name]}
  
  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  context "line is 81 chars, no newline" do
    let(:file_name) { :long_line_no_newline }
    specify { critic.problems[file_name.to_s].size.should be 1 }
    specify { critic.problems[file_name.to_s].first[:type].should == "max_line_length" }
    specify { critic.problems[file_name.to_s].first[:line].should be 1 }
    specify { critic.problems[file_name.to_s].first[:column].should be 81 }
    specify { critic.problems[file_name.to_s].first[:level].should be :error }
  end

  context "line is 81 chars, plus a newline" do
    let(:file_name) { :long_line_newline_at_82 }
    specify { critic.problems[file_name.to_s].size.should be 1 }
    specify { critic.problems[file_name.to_s].first[:type].should == "max_line_length" }
    specify { critic.problems[file_name.to_s].first[:line].should be 1 }
    specify { critic.problems[file_name.to_s].first[:column].should be 81 }
    specify { critic.problems[file_name.to_s].first[:level].should be :error }
  end
end
