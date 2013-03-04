require_relative '../../spec_helper'
require_relative '../../support/bad_indentation_cases'
require 'tailor/critic'
require 'tailor/configuration/style'


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

  let(:contents) { INDENT_1[file_name] }

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  context "simple classes" do
    context "empty with an indented end" do
      let(:file_name) { 'class_indented_end' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 2 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "body extra indented" do
      let(:file_name) { 'class_indented_single_statement' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 2 }
      specify { critic.problems[file_name].first[:column].should be 3 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "body extra indented, trailing comment" do
      let(:file_name) { 'class_indented_single_statement_trailing_comment' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 2 }
      specify { critic.problems[file_name].first[:column].should be 3 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "body extra outdented" do
      let(:file_name) { 'class_outdented_single_statement' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 2 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end
  end

  context "simple methods" do
    context "empty with an indented end" do
      let(:file_name) { 'def_indented_end' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 2 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "body and end extra indented" do
      let(:file_name) { 'def_content_indented_end' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 3 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "in a class, end outdented" do
      let(:file_name) { 'class_def_content_outdented_end' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 4 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "in a class, body outdented" do
      let(:file_name) { 'class_def_outdented_content' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 3 }
      specify { critic.problems[file_name].first[:column].should be 3 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "class method outdented, in a class" do
      let(:file_name) { 'class_method_def_using_self_outdented' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 2 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end
  end

  context "case statements" do
    context "case extra indented" do
      let(:file_name) { 'case_indented_whens_level' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 2 }
      specify { critic.problems[file_name].first[:column].should be 3 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "case extra indented, trailing comment" do
      let(:file_name) { 'case_indented_whens_level_trailing_comment' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 2 }
      specify { critic.problems[file_name].first[:column].should be 3 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "case extra outdented" do
      let(:file_name) { 'case_outdented_whens_level' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 2 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "when extra intdented" do
      let(:file_name) { 'case_when_indented_whens_level' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 3 }
      specify { critic.problems[file_name].first[:column].should be 3 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "when extra outdented" do
      let(:file_name) { 'case_when_outdented_whens_level' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 3 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "case extra indented" do
      pending "Implementation of option to allow whens in"

=begin
      let(:file_name) { 'case_indented_whens_in' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 2 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
=end
    end
  end

  context "while/do loops" do
    context "while/do indented" do
      let(:file_name) { 'while_do_indented' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "while/do outdented" do
      let(:file_name) { 'while_do_outdented' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 2 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "while/do content outdented" do
      let(:file_name) { 'while_do_content_outdented' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 3 }
      specify { critic.problems[file_name].first[:column].should be 3 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "while/do content indented" do
      let(:file_name) { 'while_do_content_indented' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 3 }
      specify { critic.problems[file_name].first[:column].should be 5 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "another while/do indented" do
      let(:file_name) { 'while_do_indented2' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 4 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "another while/do indented, trailing comment" do
      let(:file_name) { 'while_do_indented2_trailing_comment' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 4 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end
  end

  context "until/do loops" do
    context "until indented" do
      let(:file_name) { 'until_do_indented' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 4 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end
  end

  context "for/do loops" do
    context "for indented" do
      let(:file_name) { 'for_do_indented' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end
  end

  context "loop/do loops" do
    context "loop indented" do
      let(:file_name) { 'loop_do_indented' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 1 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end
  end

  context "if statements" do
    context "first line extra indented" do
      let(:file_name) { 'if_line_indented' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 2 }
      specify { critic.problems[file_name].first[:column].should be 3 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "first line extra indented, trailing comment" do
      let(:file_name) { 'if_line_indented_trailing_comment' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 2 }
      specify { critic.problems[file_name].first[:column].should be 3 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end
  end

  context "multi_line_tstring" do
    let(:file_name) { 'multi_line_tstring' }
    specify { critic.problems[file_name].size.should be 1 }
    specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
    specify { critic.problems[file_name].first[:line].should be 2 }
    specify { critic.problems[file_name].first[:column].should be 0 }
    specify { critic.problems[file_name].first[:level].should be :error }
  end

  context "operators" do
    context "multi-line &&, first line indented" do
      let(:file_name) { 'multi_line_andop_first_line_indented' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 2 }
      specify { critic.problems[file_name].first[:column].should be 3 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "multi-line &&, first line indented, trailing comment" do
      let(:file_name) { 'multi_line_andop_first_line_indented_trailing_comment' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 2 }
      specify { critic.problems[file_name].first[:column].should be 3 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "multi-line &&, second line indented" do
      let(:file_name) { 'multi_line_andop_second_line_indented' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 3 }
      specify { critic.problems[file_name].first[:column].should be 5 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "multi-line string concat, second line outdented" do
      let(:file_name) { 'multi_line_string_concat_with_plus_out' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 2 }
      specify { critic.problems[file_name].first[:column].should be 1 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end
  end

  context "combinations of stuff" do
    context "multi-line if with end in" do
      let(:file_name) { 'multi_line_method_call_end_in' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 5 }
      specify { critic.problems[file_name].first[:column].should be 3 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "multi-line chained methods with 2nd line in" do
      let(:file_name) { 'multi_line_method_call_ends_with_period_2nd_line_in' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 4 }
      specify { critic.problems[file_name].first[:column].should be 5 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "multi-line chained methods with 3rd line in" do
      let(:file_name) { 'multi_line_method_call_ends_with_many_periods_last_in' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 3 }
      specify { critic.problems[file_name].first[:column].should be 4 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end

    context "multi-line chained methods with 3rd line in, trailing comment" do
      let(:file_name) { 'multi_line_method_call_ends_with_many_periods_last_in_trailing_comment' }
      specify { critic.problems[file_name].size.should be 1 }
      specify { critic.problems[file_name].first[:type].should == "indentation_spaces" }
      specify { critic.problems[file_name].first[:line].should be 3 }
      specify { critic.problems[file_name].first[:column].should be 4 }
      specify { critic.problems[file_name].first[:level].should be :error }
    end
  end
end
