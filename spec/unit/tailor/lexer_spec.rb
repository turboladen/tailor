require 'spec_helper'
require 'tailor/lexer'

describe Tailor::Lexer do
  let!(:file_text) { '' }
  let(:style) { {} }
  let(:indentation_ruler) { double 'IndentationSpacesRuler' }

  subject do
    r = Tailor::Lexer.new(file_text)
    r.instance_variable_set(:@buf, [])
    allow(r).to receive(:log)

    r
  end

  before do
    allow_any_instance_of(Tailor::Lexer).to receive(:ensure_trailing_newline).
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
        expect(file).to receive(:read).and_return file_text
        expect(File).to receive(:open).with('test', 'r').and_return file
        Tailor::Lexer.new(file_name)
      end
    end

    context 'text to lex is passed in' do
      let(:text) { 'some text' }

      it 'does not try to open a file' do
        expect(File).to_not receive(:open)
        Tailor::Lexer.new(text)
      end
    end
  end

  describe '#on_sp' do
    context 'token is a backslash then newline' do
      it 'calls #notify_ignored_nl_observers' do
        expect(subject).to receive(:notify_ignored_nl_observers)
        subject.on_sp("\\\n")
      end
    end
  end

  describe '#current_line_of_text' do
    before do
      subject.instance_variable_set(:@file_text, file_text)
      allow(subject).to receive(:lineno).and_return 1
    end

    context '@file_text is 1 line with 0 \ns' do
      let(:file_text) { "puts 'code'" }

      it 'returns the line' do
        expect(subject.current_line_of_text).to eq file_text
      end
    end

    context '@file_text is 1 empty line with 0 \ns' do
      let(:file_text) { '' }

      it 'returns the an empty string' do
        expect(subject.current_line_of_text).to eq file_text
      end
    end

    context '@file_text is 1 empty line with 1 \n' do
      let(:file_text) { "\n" }

      it 'returns an empty string' do
        expect(subject.current_line_of_text).to eq ''
      end
    end
  end

  describe '#count_trailing_newlines' do
    context 'text contains 0 trailing \n' do
      let(:text) { 'text' }
      specify { expect(subject.count_trailing_newlines(text)).to be_zero }
    end

    context 'text contains 1 trailing \n' do
      let(:text) { "text\n" }
      specify { expect(subject.count_trailing_newlines(text)).to eq 1 }
    end
  end

  describe '#ensure_trailing_newline' do
    before do
      Tailor::Lexer.any_instance.unstub(:ensure_trailing_newline)
    end

    context 'text contains a trailing newline already' do
      let!(:text) { "text\n" }

      before do
        allow(subject).to receive(:count_trailing_newlines).and_return 1
      end

      it 'does not alter the text' do
        expect(subject.ensure_trailing_newline(text)).to eq text
      end
    end

    context 'text does not contain a trailing newline' do
      let!(:text) { 'text' }

      it 'adds a newline at the end' do
        expect(subject.ensure_trailing_newline(text)).to eq(text + "\n")
      end
    end
  end

  describe '#sub_line_ending_backslashes' do
    let!(:text) do
      %(command \\
  'something')
    end

    before do
      def subject.sub_publicly(file_text)
        sub_line_ending_backslashes(file_text)
      end
    end

    it 'replaces all line-ending backslashes with a comment' do
      expect(subject.sub_publicly(text)).to eq %(command # TAILOR REMOVED BACKSLASH
  'something')
    end
  end
end
