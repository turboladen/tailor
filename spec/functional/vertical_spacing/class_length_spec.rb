require_relative '../../spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'


CLASS_LENGTH = {}
CLASS_LENGTH[:class_too_long] =
  %Q{class Party
  include Clowns
  include Pizza

  def barrel_roll
    puts "DOABARRELROLL!"
  end
end}

CLASS_LENGTH[:parent_class_too_long] =
  %Q{class Party

  class Pizza
    include Cheese
    include Yumminess
  end
end}


describe "Detection of class length" do
  before do
    Tailor::Logger.stub(:log)
    FakeFS.activate!
    File.open(file_name.to_s, 'w') { |f| f.write contents }
    critic.check_file(file_name.to_s, style.to_hash)
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:contents) { CLASS_LENGTH[file_name] }

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off
    style.max_code_lines_in_class 5

    style
  end

  context "single class" do
    let(:file_name) { :class_too_long }
    specify { critic.problems[file_name.to_s].size.should be 1 }
    specify { critic.problems[file_name.to_s].first[:type].should == "max_code_lines_in_class" }
    specify { critic.problems[file_name.to_s].first[:line].should be 1 }
    specify { critic.problems[file_name.to_s].first[:column].should be 0 }
    specify { critic.problems[file_name.to_s].first[:level].should be :error }
  end
  
  context "class in a class" do
    let(:file_name) { :parent_class_too_long }
    specify { critic.problems[file_name.to_s].size.should be 1 }
    specify { critic.problems[file_name.to_s].first[:type].should == "max_code_lines_in_class" }
    specify { critic.problems[file_name.to_s].first[:line].should be 1 }
    specify { critic.problems[file_name.to_s].first[:column].should be 0 }
    specify { critic.problems[file_name.to_s].first[:level].should be :error }
  end
end
