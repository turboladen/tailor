require 'spec_helper'
require_relative '../../support/bad_indentation_cases'
require 'tailor/critic'
require 'tailor/configuration/style'

describe 'Detection of method length' do
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

  context 'simple classes' do
    context 'empty with an indented end' do
      let(:file_name) { 'class_indented_end' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'body extra indented' do
      let(:file_name) { 'class_indented_single_statement' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'body extra indented, trailing comment' do
      let(:file_name) { 'class_indented_single_statement_trailing_comment' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'body extra outdented' do
      let(:file_name) { 'class_outdented_single_statement' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end
  end

  context 'simple methods' do
    context 'empty with an indented end' do
      let(:file_name) { 'def_indented_end' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'body and end extra indented' do
      let(:file_name) { 'def_content_indented_end' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'in a class, end outdented' do
      let(:file_name) { 'class_def_content_outdented_end' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 4 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'in a class, body outdented' do
      let(:file_name) { 'class_def_outdented_content' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'class method outdented, in a class' do
      let(:file_name) { 'class_method_def_using_self_outdented' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end
  end

  context 'case statements' do
    context 'case extra indented' do
      let(:file_name) { 'case_indented_whens_level' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'case extra indented, trailing comment' do
      let(:file_name) { 'case_indented_whens_level_trailing_comment' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'case extra outdented' do
      let(:file_name) { 'case_outdented_whens_level' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'when extra intdented' do
      let(:file_name) { 'case_when_indented_whens_level' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'when extra outdented' do
      let(:file_name) { 'case_when_outdented_whens_level' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'case extra indented' do
      pending 'Implementation of option to allow whens in'

      # let(:file_name) { 'case_indented_whens_in' }
      # specify { expect(critic.problems[file_name].size).to eq 1 }
      # specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      # specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      # specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      # specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end
  end

  context 'while/do loops' do
    context 'while/do indented' do
      let(:file_name) { 'while_do_indented' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'while/do outdented' do
      let(:file_name) { 'while_do_outdented' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'while/do content outdented' do
      let(:file_name) { 'while_do_content_outdented' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'while/do content indented' do
      let(:file_name) { 'while_do_content_indented' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 5 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'another while/do indented' do
      let(:file_name) { 'while_do_indented2' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 4 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'another while/do indented, trailing comment' do
      let(:file_name) { 'while_do_indented2_trailing_comment' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 4 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end
  end

  context 'until/do loops' do
    context 'until indented' do
      let(:file_name) { 'until_do_indented' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 4 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end
  end

  context 'for/do loops' do
    context 'for indented' do
      let(:file_name) { 'for_do_indented' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end
  end

  context 'loop/do loops' do
    context 'loop indented' do
      let(:file_name) { 'loop_do_indented' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end
  end

  context 'if statements' do
    context 'first line extra indented' do
      let(:file_name) { 'if_line_indented' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'first line extra indented, trailing comment' do
      let(:file_name) { 'if_line_indented_trailing_comment' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end
  end

  context 'multi_line_tstring' do
    let(:file_name) { 'multi_line_tstring' }
    specify { expect(critic.problems[file_name].size).to eq 1 }
    specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
    specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
    specify { expect(critic.problems[file_name].first[:column]).to eq 0 }
    specify { expect(critic.problems[file_name].first[:level]).to eq :error }
  end

  context 'operators' do
    context 'multi-line &&, first line indented' do
      let(:file_name) { 'multi_line_andop_first_line_indented' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'multi-line &&, first line indented, trailing comment' do
      let(:file_name) { 'multi_line_andop_first_line_indented_trailing_comment' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'multi-line &&, second line indented' do
      let(:file_name) { 'multi_line_andop_second_line_indented' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 5 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'multi-line string concat, second line outdented' do
      let(:file_name) { 'multi_line_string_concat_with_plus_out' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 1 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end
  end

  context 'combinations of stuff' do
    context 'multi-line if with end in' do
      let(:file_name) { 'multi_line_method_call_end_in' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 5 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'multi-line chained methods with 2nd line in' do
      let(:file_name) { 'multi_line_method_call_ends_with_period_2nd_line_in' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 4 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 5 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'multi-line chained methods with 3rd line in' do
      let(:file_name) { 'multi_line_method_call_ends_with_many_periods_last_in' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 4 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end

    context 'multi-line chained methods with 3rd line in, trailing comment' do
      let(:file_name) { 'multi_line_method_call_ends_with_many_periods_last_in_trailing_comment' }
      specify { expect(critic.problems[file_name].size).to eq 1 }
      specify { expect(critic.problems[file_name].first[:type]).to eq 'indentation_spaces' }
      specify { expect(critic.problems[file_name].first[:line]).to eq 3 }
      specify { expect(critic.problems[file_name].first[:column]).to eq 4 }
      specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    end
  end
end
