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

  context 'hard tabs' do
    let(:style) do
      style = Tailor::Configuration::Style.new
      style.trailing_newlines 0, level: :off
      style.allow_invalid_ruby true, level: :off
      style.indentation_spaces 2, level: :off

      style
    end

    context "1 hard tab" do
      let(:file_name) { :hard_tab }
      let(:contents) { HARD_TABS_1[file_name]}

      before do
        File.open(file_name.to_s, 'w') { |f| f.write contents }
        critic.check_file(file_name.to_s, style.to_hash)
      end

      it "should find 1 problem" do
        critic.problems[file_name.to_s].should == [{
          type: "allow_hard_tabs",
          line: 2,
          column: 0,
          message: 'Hard tab found.',
          level: :error
        }]
      end

    end


  end
=begin
  H_SPACING_1.each do |file_name, contents|
    before do
      FileUtils.touch file_name.to_s
      File.open(file_name.to_s, 'w') { |f| f.write contents }
    end

    it "should find 1 problem" do
      critic.check_file(file_name.to_s, style.to_hash)

      begin
        critic.problems.first.size.should be 1
      rescue RSpec::Expectations::ExpectationNotMetError => ex
        #pp critic.problems
        raise ex.class, critic.problems
      end
    end
  end

  H_SPACING_2.each do |file_name, contents|
    before do
      FileUtils.touch file_name.to_s
      File.open(file_name.to_s, 'w') { |f| f.write contents }
    end

    it "should find 2 problems" do
      critic.check_file(file_name.to_s, style.to_hash)

      begin
        critic.problems.first.size.should be 2
      rescue RSpec::Expectations::ExpectationNotMetError => ex
        #pp critic.problems
        raise ex.class, critic.problems
      end
    end
  end
=end
end
