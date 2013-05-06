require 'spec_helper'
require 'tailor/lexer'

describe Tailor::Lexer do
  let!(:file_text) { '' }
  let(:style) { {} }
  let(:indentation_ruler) { double 'IndentationSpacesRuler' }

  subject do
    r = Tailor::Lexer.new(file_text)
    r.instance_variable_set(:@buf, [])
    r.stub(:log)

    r
  end

  before do
    Tailor::Lexer.any_instance.stub(:ensure_trailing_newline).
      and_return(file_text)
  end

  describe '#initialize' do
    context 'name of file is passed in' do
      let(:file_name) { 'test' }

      before do
        File.open(file_name, 'w') { |f| f.write 'some text' }
      end

      it 'opens and reads the file by the name passed in' do
        file = double 'File'
        file.should_receive(:read).and_return file_text
        File.should_receive(:open).with('test', 'r').and_return file
        Tailor::Lexer.new(file_name)
      end
    end

    context 'text to lex is passed in' do
      let(:text) { 'some text' }

      it 'does not try to open a file' do
        File.should_not_receive(:open)
        Tailor::Lexer.new(text)
      end
    end
  end

  describe '#on_sp' do
    context 'token is a backslash then newline' do
      it 'calls #notify_ignored_nl_observers' do
        subject.should_receive(:notify_ignored_nl_observers)
        subject.on_sp("\\\n")
      end
    end
  end

  describe '#current_line_of_text' do
    before do
      subject.instance_variable_set(:@file_text, file_text)
      subject.stub(:lineno).and_return 1
    end

    context "@file_text is 1 line with 0 \\ns" do
      let(:file_text) { "puts 'code'" }

      it 'returns the line' do
        subject.current_line_of_text.should == file_text
      end
    end

    context "@file_text is 1 empty line with 0 \\ns" do
      let(:file_text) { '' }

      it 'returns the an empty string' do
        subject.current_line_of_text.should == file_text
      end
    end

    context "@file_text is 1 empty line with 1 \\n" do
      let(:file_text) { "\n" }

      it 'returns an empty string' do
        subject.current_line_of_text.should == ''
      end
    end
  end

  describe '#count_trailing_newlines' do
    context "text contains 0 trailing \\n" do
      let(:text) { 'text' }
      specify { subject.count_trailing_newlines(text).should be_zero }
    end

    context "text contains 1 trailing \\n" do
      let(:text) { "text\n" }
      specify { subject.count_trailing_newlines(text).should == 1 }
    end
  end

  describe '#ensure_trailing_newline' do
    before do
      Tailor::Lexer.any_instance.unstub(:ensure_trailing_newline)
    end

    context 'text contains a trailing newline already' do
      let!(:text) { "text\n" }

      before do
        subject.stub(:count_trailing_newlines).and_return 1
      end

      it 'does not alter the text' do
        subject.ensure_trailing_newline(text).should == text
      end
    end

    context 'text does not contain a trailing newline' do
      let!(:text) { 'text' }

      it 'adds a newline at the end' do
        subject.ensure_trailing_newline(text).should == text + "\n"
      end
    end
  end
  
  describe '#sub_line_ending_backslashes' do
    let!(:text) do
      %Q{command \\
  'something'}
    end
    
    before do
      def subject.sub_publicly(file_text)
        sub_line_ending_backslashes(file_text)
      end
    end
    
    it 'replaces all line-ending backslashes with a comment' do
      subject.sub_publicly(text).should == %Q{command # TAILOR REMOVED BACKSLASH
  'something'}
    end
  end
end
