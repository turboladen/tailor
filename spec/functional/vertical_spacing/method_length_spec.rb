require_relative '../../spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'


METHOD_LENGTH = {}
METHOD_LENGTH['method_too_long'] =
  %Q{def thing
  puts
  puts
end}

METHOD_LENGTH['parent_method_too_long'] =
  %Q{def thing
  puts
  def inner_thing; print '1'; end
  puts
end}


describe "Detection of method length" do
  before do
    Tailor::Logger.stub(:log)
    FakeFS.activate!
    File.open(file_name, 'w') { |f| f.write contents }
    critic.check_file(file_name, style.to_hash)
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:contents) { METHOD_LENGTH[file_name] }

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off
    style.max_code_lines_in_method 3

    style
  end

  context "single class too long" do
    let(:file_name) { 'method_too_long' }
    specify { critic.problems[file_name].size.should be 1 }
    specify { critic.problems[file_name].first[:type].should == "max_code_lines_in_method" }
    specify { critic.problems[file_name].first[:line].should be 1 }
    specify { critic.problems[file_name].first[:column].should be 0 }
    specify { critic.problems[file_name].first[:level].should be :error }
  end

  context "method in a method" do
    let(:file_name) { 'method_too_long' }
    specify { critic.problems[file_name].size.should be 1 }
    specify { critic.problems[file_name].first[:type].should == "max_code_lines_in_method" }
    specify { critic.problems[file_name].first[:line].should be 1 }
    specify { critic.problems[file_name].first[:column].should be 0 }
    specify { critic.problems[file_name].first[:level].should be :error }
  end
end
