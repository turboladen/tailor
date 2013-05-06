require 'spec_helper'
require 'tailor/critic'


describe Tailor::Critic do
  before { Tailor::Logger.stub(:log) }

  describe '#check_file' do
    let(:lexer) { double 'Lexer' }
    let(:ruler) { double 'Ruler' }
    let(:style) { double 'Style', each: nil }
    let(:file_name) { 'this_file.rb' }

    before do
      subject.stub(:init_rulers)
    end

    it 'lexes the file' do
      lexer.should_receive(:lex)
      lexer.stub(:check_added_newline)
      Tailor::Lexer.should_receive(:new).with(file_name).and_return lexer
      subject.stub_chain(:problems, :[]=)
      subject.stub_chain(:problems, :[])

      subject.check_file(file_name, style)
    end

    it 'adds problems for the file to the main list of problems' do
      lexer.stub(:lex)
      lexer.stub(:check_added_newline)
      Tailor::Lexer.stub(:new).and_return lexer
      subject.problems.should_receive(:[]=).with(file_name, [])

      subject.check_file(file_name, style)
    end
  end

  describe '#problems' do
    specify { subject.problems.should be_a Hash }
    specify { subject.problems.should be_empty }
  end

  describe '#problem_count' do
    context '#problems is empty' do
      it 'returns 0' do
        subject.instance_variable_set(:@problems, {})
        subject.problem_count.should == 0
      end
    end

    context '#problems contains valid values' do
      it 'adds the number of each problem together' do
        probs = {
          one: { type: :indentation, line: 1, message: '' },
          two: { type: :indentation, line: 2, message: '' },
          thre: { type: :indentation, line: 27, message: '' }
        }
        subject.instance_variable_set(:@problems, probs)
        subject.problem_count.should == 3
      end
    end
  end
end
