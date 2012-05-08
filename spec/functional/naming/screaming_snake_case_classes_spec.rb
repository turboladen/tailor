require_relative '../../spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'


SCREAMING_SNAKE_CASE_CLASSES = {}

SCREAMING_SNAKE_CASE_CLASSES[:one_screaming_snake_case_class] =
  %Q{class Thing_One
end}

SCREAMING_SNAKE_CASE_CLASSES[:one_screaming_snake_case_module] =
  %Q{module Thing_One
end}

SCREAMING_SNAKE_CASE_CLASSES[:double_screaming_snake_case_class] =
  %Q{class Thing_One_Again
end}

SCREAMING_SNAKE_CASE_CLASSES[:double_screaming_snake_case_module] =
  %Q{module Thing_One_Again
end}



describe "Detection of camel case methods" do
  before do
    Tailor::Logger.stub(:log)
    FakeFS.activate!
    File.open(file_name.to_s, 'w') { |f| f.write contents }
    critic.check_file(file_name.to_s, style.to_hash)
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:contents) { SCREAMING_SNAKE_CASE_CLASSES[file_name] }

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  context "standard screaming snake case class" do
    let(:file_name) { :one_screaming_snake_case_class }
    specify { critic.problems[file_name.to_s].size.should be 1 }
    specify { critic.problems[file_name.to_s].first[:type].should == "allow_screaming_snake_case_classes" }
    specify { critic.problems[file_name.to_s].first[:line].should be 1 }
    specify { critic.problems[file_name.to_s].first[:column].should be 6 }
    specify { critic.problems[file_name.to_s].first[:level].should be :error }
  end
  
  context "standard screaming snake case module" do
    let(:file_name) { :one_screaming_snake_case_module }
    specify { critic.problems[file_name.to_s].size.should be 1 }
    specify { critic.problems[file_name.to_s].first[:type].should == "allow_screaming_snake_case_classes" }
    specify { critic.problems[file_name.to_s].first[:line].should be 1 }
    specify { critic.problems[file_name.to_s].first[:column].should be 7 }
    specify { critic.problems[file_name.to_s].first[:level].should be :error }
  end

  context "double screaming snake case class" do
    let(:file_name) { :double_screaming_snake_case_class }
    specify { critic.problems[file_name.to_s].size.should be 1 }
    specify { critic.problems[file_name.to_s].first[:type].should == "allow_screaming_snake_case_classes" }
    specify { critic.problems[file_name.to_s].first[:line].should be 1 }
    specify { critic.problems[file_name.to_s].first[:column].should be 6 }
    specify { critic.problems[file_name.to_s].first[:level].should be :error }
  end

  context "double screaming snake case module" do
    let(:file_name) { :double_screaming_snake_case_module }
    specify { critic.problems[file_name.to_s].size.should be 1 }
    specify { critic.problems[file_name.to_s].first[:type].should == "allow_screaming_snake_case_classes" }
    specify { critic.problems[file_name.to_s].first[:line].should be 1 }
    specify { critic.problems[file_name.to_s].first[:column].should be 7 }
    specify { critic.problems[file_name.to_s].first[:level].should be :error }
  end
end
