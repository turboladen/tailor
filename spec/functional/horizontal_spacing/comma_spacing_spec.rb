require 'spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'


COMMA_SPACING = {}
COMMA_SPACING['no_space_after_comma'] = %Q{[1,2]}
COMMA_SPACING['two_spaces_after_comma'] = %Q{[1,  2]}
COMMA_SPACING['one_space_before_comma'] = %Q{[1 , 2]}
COMMA_SPACING['two_spaces_before_comma'] = %Q{[1  , 2]}
COMMA_SPACING['two_spaces_before_comma_twice'] = %Q{[1  , 2  , 3]}
COMMA_SPACING['two_spaces_after_comma_twice'] = %Q{[1,  2,  3]}

COMMA_SPACING['spaces_before_with_trailing_comments'] = %Q{[
  1 ,   # Comment!
  2 ,   # Another comment.
}


describe 'Spacing around comma detection' do
  before do
    Tailor::Logger.stub(:log)
    FakeFS.activate!
    File.open(file_name, 'w') { |f| f.write contents }
    critic.check_file(file_name, style.to_hash)
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:contents) { COMMA_SPACING[file_name]}

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  context 'no space after a comma' do
    let(:file_name) { 'no_space_after_comma' }
    specify { critic.problems[file_name].size.should be 1 }
    specify { critic.problems[file_name].first[:type].should == 'spaces_after_comma' }
    specify { critic.problems[file_name].first[:line].should be 1 }
    specify { critic.problems[file_name].first[:column].should be 3 }
    specify { critic.problems[file_name].first[:level].should be :error }
  end

  context 'two spaces after a comma' do
    let(:file_name) { 'two_spaces_after_comma' }
    specify { critic.problems[file_name].size.should be 1 }
    specify { critic.problems[file_name].first[:type].should == 'spaces_after_comma' }
    specify { critic.problems[file_name].first[:line].should be 1 }
    specify { critic.problems[file_name].first[:column].should be 3 }
    specify { critic.problems[file_name].first[:level].should be :error }
  end

  context 'one space before comma' do
    let(:file_name) { 'one_space_before_comma' }
    specify { critic.problems[file_name].size.should be 1 }
    specify { critic.problems[file_name].first[:type].should == 'spaces_before_comma' }
    specify { critic.problems[file_name].first[:line].should be 1 }
    specify { critic.problems[file_name].first[:column].should be 2 }
    specify { critic.problems[file_name].first[:level].should be :error }
  end
end
