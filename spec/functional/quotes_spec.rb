require_relative '../spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'

describe "Consistent usage of quotes" do
  before do
    Tailor::Logger.stub(:log)
    FakeFS.activate!
    File.open(file_name.to_s, 'w') { |f| f.write contents }
    critic.check_file(file_name.to_s, style.to_hash)
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:contents) {
    {
      :single_quotes => %Q{a = 'test'},
      :double_quotes => %Q{a = "test"},
      :mixed_quotes => %Q{a = 'test'; b = "test"},
      :special_quotes => %Q{a = %q(test); b = %Q(test)}
    }[file_name]
  }


  describe "single quotes" do
    let(:style) do
      style = Tailor::Configuration::Style.new
      style.trailing_newlines 0, level: :off
      style.allow_invalid_ruby true, level: :off
      style.quotes "single", level: :error
      style
    end

    context "ok" do
      let(:file_name) { :single_quotes }

      specify { critic.problems[file_name.to_s].size.should == 0 }
    end
    context "double quotes" do
      let(:file_name) { :double_quotes }

      specify { critic.problems[file_name.to_s].size.should == 1 }
      specify { critic.problems[file_name.to_s].first[:type].should == "quotes" }
      specify { critic.problems[file_name.to_s].first[:line].should be 1 }
      specify { critic.problems[file_name.to_s].first[:column].should be 4 }
      specify { critic.problems[file_name.to_s].first[:level].should be :error }
    end
    context "mixed quotes" do
      let(:file_name) { :mixed_quotes }

      specify { critic.problems[file_name.to_s].size.should == 1 }
      specify { critic.problems[file_name.to_s].first[:type].should == "quotes" }
      specify { critic.problems[file_name.to_s].first[:line].should be 1 }
      specify { critic.problems[file_name.to_s].first[:column].should be 16 }
      specify { critic.problems[file_name.to_s].first[:level].should be :error }
    end
    context "special quotes" do
      let(:file_name) { :special_quotes }

      specify { critic.problems[file_name.to_s].size.should == 0 }
    end
  end

  describe "double quotes" do
    let(:style) do
      style = Tailor::Configuration::Style.new
      style.trailing_newlines 0, level: :off
      style.allow_invalid_ruby true, level: :off
      style.quotes "double", level: :error
      style
    end

    context "ok" do
      let(:file_name) { :double_quotes }

      specify { critic.problems[file_name.to_s].size.should == 0 }
    end

    context "single quotes" do
      let(:file_name) { :single_quotes }

      specify { critic.problems[file_name.to_s].size.should == 1 }
      specify { critic.problems[file_name.to_s].first[:type].should == "quotes" }
      specify { critic.problems[file_name.to_s].first[:line].should be 1 }
      specify { critic.problems[file_name.to_s].first[:column].should be 4 }
      specify { critic.problems[file_name.to_s].first[:level].should be :error }
    end

    context "mixed quotes" do
      let(:file_name) { :mixed_quotes }

      specify { critic.problems[file_name.to_s].size.should == 1 }
      specify { critic.problems[file_name.to_s].first[:type].should == "quotes" }
      specify { critic.problems[file_name.to_s].first[:line].should be 1 }
      specify { critic.problems[file_name.to_s].first[:column].should be 4 }
      specify { critic.problems[file_name.to_s].first[:level].should be :error }
    end

    context "special quotes" do
      let(:file_name) { :special_quotes }

      specify { critic.problems[file_name.to_s].size.should == 0 }
    end
  end
end
