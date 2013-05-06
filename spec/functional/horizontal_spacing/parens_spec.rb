require 'spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'


PARENS = {}
PARENS['simple_method_call_space_after_lparen'] = %Q{thing( one, two)}
PARENS['simple_method_call_space_before_rparen'] = %Q{thing(one, two )}
PARENS['method_call_space_after_lparen_trailing_comment'] =
  %Q{thing( one, two)    # comment}
PARENS['method_call_space_after_lparen_before_rparen_trailing_comment'] =
  %Q{thing( one, two )    # comment}

PARENS['multi_line_method_call_space_after_lparen'] = %Q{thing( one,
  two)}
PARENS['multi_line_method_call_space_after_lparen_trailing_comment'] =
  %Q{thing( one,
  two)}

describe 'Detection of spaces around brackets' do
  before do
    Tailor::Logger.stub(:log)
    FakeFS.activate!
    File.open(file_name, 'w') { |f| f.write contents }
    critic.check_file(file_name, style.to_hash)
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:contents) { PARENS[file_name]}

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  context 'methods' do
    context 'space after lparen' do
      let(:file_name) { 'simple_method_call_space_after_lparen' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == 'spaces_after_lparen' }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 6 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context 'space before rparen' do
      let(:file_name) { 'simple_method_call_space_before_rparen' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == 'spaces_before_rparen' }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 15 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context 'space after lparen, trailing comment' do
      let(:file_name) { 'method_call_space_after_lparen_trailing_comment' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == 'spaces_after_lparen' }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 6 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context 'space after lparen, before rparen, trailing comment' do
      let(:file_name) { 'method_call_space_after_lparen_before_rparen_trailing_comment' }
      specify { critic.problems[file_name].size.should be 2 }
      specify { critic.problems[file_name].first[:type].should == 'spaces_after_lparen' }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 6 }
      specify { critic.problems[file_name].first[:level].should be :error }
      specify { critic.problems[file_name].last[:type].should == 'spaces_before_rparen' }
      specify { critic.problems[file_name].last[:line].should be 1 }
      specify { critic.problems[file_name].last[:column].should be 16 }
      specify { critic.problems[file_name].last[:level].should be :error }
    end
  end

  context 'multi-line method calls' do
    context 'space after lparen' do
      let(:file_name) { 'multi_line_method_call_space_after_lparen' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == 'spaces_after_lparen' }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 6 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end
    context 'space after lparen, trailing comment' do
      let(:file_name) { 'multi_line_method_call_space_after_lparen_trailing_comment' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == 'spaces_after_lparen' }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 6 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end
  end
end
