require_relative '../spec_helper'
require_relative '../support/horizontal_spacing_cases'
require 'tailor/critic'
require 'tailor/configuration/style'

describe "Horizontal Space problem detection" do
  before do
    Tailor::Logger.stub(:log)
    FakeFS.activate!
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  H_SPACING_OK.each do |file_name, contents|
    before do
      FileUtils.touch file_name.to_s
      File.open(file_name.to_s, 'w') { |f| f.write contents }
    end

    it "should be OK" do
      critic.check_file(file_name.to_s, style.to_hash)
      critic.problems.should == { file_name.to_s =>  [] }
    end
  end
  
  context "line ends with a backslash" do
    let(:file_name) { :line_split_by_backslash }
    
    let(:contents) do
      %Q{execute 'myscript' do
  command \\
    '/some/really/long/path/that/would/be/over/eighty/chars.sh'
  only_if { something }
end}
    end
      
    before do
      FileUtils.touch file_name.to_s
      File.open(file_name.to_s, 'w') { |f| f.write contents }
    end
    
    it "is OK" do
      pending "Fix of gh-101"
      
      critic.check_file(file_name.to_s, style.to_hash)
      critic.problems.should == { file_name.to_s =>  [] }
    end
  end
end
