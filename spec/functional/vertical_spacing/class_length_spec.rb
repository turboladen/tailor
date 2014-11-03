require 'spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'

CLASS_LENGTH = {}
CLASS_LENGTH['class_too_long'] =
  %(class Party
  include Clowns
  include Pizza

  def barrel_roll
    puts 'DOABARRELROLL!'
  end
end)

CLASS_LENGTH['parent_class_too_long'] =
  %(class Party

  class Pizza
    include Cheese
    include Yumminess
  end
end)

describe 'Detection of class length' do
  before do
    Tailor::Logger.stub(:log)
    FakeFS.activate!
    File.open(file_name, 'w') { |f| f.write contents }
    critic.check_file(file_name, style.to_hash)
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

  context 'single class' do
    let(:file_name) { 'class_too_long' }
    specify { critic.problems[file_name].size.should be 1 }
    specify { critic.problems[file_name].first[:type].should == 'max_code_lines_in_class' }
    specify { critic.problems[file_name].first[:line].should be 1 }
    specify { critic.problems[file_name].first[:column].should be 0 }
    specify { critic.problems[file_name].first[:level].should be :error }
  end

  context 'class in a class' do
    let(:file_name) { 'parent_class_too_long' }
    specify { critic.problems[file_name].size.should be 1 }
    specify { critic.problems[file_name].first[:type].should == 'max_code_lines_in_class' }
    specify { critic.problems[file_name].first[:line].should be 1 }
    specify { critic.problems[file_name].first[:column].should be 0 }
    specify { critic.problems[file_name].first[:level].should be :error }
  end
end
