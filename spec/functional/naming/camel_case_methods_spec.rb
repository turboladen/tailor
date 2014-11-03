require 'spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'

CAMEL_CASE_METHODS = {}

CAMEL_CASE_METHODS['one_caps_camel_case_method'] =
  %(def thingOne
end)

CAMEL_CASE_METHODS['one_caps_camel_case_method_trailing_comment'] =
  %(def thingOne   # comment
end)

describe 'Detection of camel case methods' do
  before do
    Tailor::Logger.stub(:log)
    FakeFS.activate!
    File.open(file_name, 'w') { |f| f.write contents }
    critic.check_file(file_name, style.to_hash)
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:contents) { CAMEL_CASE_METHODS[file_name] }

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  context 'standard camel case method' do
    let(:file_name) { 'one_caps_camel_case_method' }
    specify { critic.problems[file_name].size.should be 1 }
    specify { critic.problems[file_name].first[:type].should == 'allow_camel_case_methods' }
    specify { critic.problems[file_name].first[:line].should be 1 }
    specify { critic.problems[file_name].first[:column].should be 4 }
    specify { critic.problems[file_name].first[:level].should be :error }
  end

  context 'standard camel case method, trailing comment' do
    let(:file_name) { 'one_caps_camel_case_method_trailing_comment' }
    specify { critic.problems[file_name].size.should be 1 }
    specify { critic.problems[file_name].first[:type].should == 'allow_camel_case_methods' }
    specify { critic.problems[file_name].first[:line].should be 1 }
    specify { critic.problems[file_name].first[:column].should be 4 }
    specify { critic.problems[file_name].first[:level].should be :error }
  end
end
