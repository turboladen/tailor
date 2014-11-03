require 'spec_helper'
require 'tailor/rulers/indentation_spaces_ruler'
require 'ripper'

describe Tailor::Rulers::IndentationSpacesRuler do
  let!(:spaces) { 5 }
  let(:lexed_line) { double 'LexedLine' }

  subject do
    Tailor::Rulers::IndentationSpacesRuler.new(spaces, level: :error)
  end

  describe '#comment_update' do
    context 'token does not contain a trailing newline' do
      pending
    end

    context 'token contains a trailing newline' do
      context 'lexed_line is spaces then a comment' do
        pending
      end

      context 'lexed_line is no spaces and a comment' do
        pending
      end

      context 'lexed_line ends with an operator' do
        pending
      end

      context 'lexed_line ends with a comma' do
        pending
      end
    end
  end

  describe '#embexpr_beg_update' do
    it 'sets @embexpr_nesting to [true]' do
      subject.instance_variable_set(:@embexpr_nesting, [])
      subject.embexpr_beg_update(lexed_line, 1, 1)
      expect(subject.instance_variable_get(:@embexpr_nesting)).to eq [true]
    end
  end

  describe '#embexpr_end_update' do
    before do
      expect(lexed_line).to receive(:only_embexpr_end?).and_return(false)
    end

    it 'pops @embexpr_nesting' do
      subject.instance_variable_set(:@embexpr_nesting, [true])
      subject.embexpr_end_update(lexed_line, 1, 1)
      expect(subject.instance_variable_get(:@embexpr_nesting)).to eq []
    end
  end

  describe '#ignored_nl_update' do
    pending
  end

  describe '#kw_update' do
    pending
  end

  describe '#lbrace_update' do
    pending
  end

  describe '#lbracket_update' do
    pending
  end

  describe '#lparen_update' do
    pending
  end

  describe '#nl_update' do
    pending
  end

  describe '#period_update' do
    pending
  end

  describe '#rbrace_update' do
    pending
  end

  describe '#rbracket_update' do
    pending
  end

  describe '#rparen_update' do
    pending
  end

  describe '#tstring_beg_update' do
    let(:manager) { double 'IndentationManager' }

    it 'calls #stop on the indentation_manager object' do
      expect(manager).to receive(:update_actual_indentation).with lexed_line
      expect(manager).to receive(:stop)
      subject.instance_variable_set(:@manager, manager)
      subject.tstring_beg_update(lexed_line, 1)
    end

    it 'adds the lineno to @tstring_nesting' do
      allow(manager).to receive(:update_actual_indentation)
      allow(manager).to receive(:stop)
      subject.instance_variable_set(:@manager, manager)
      subject.tstring_beg_update(lexed_line, 1)
      expect(subject.instance_variable_get(:@tstring_nesting)).to eq [1]
    end
  end

  describe '#tstring_end_update' do
    context '@tstring_nesting is not empty' do
      let(:manager) { double 'IndentationManager' }

      it 'calls #start' do
        expect(manager).to receive(:start)
        subject.instance_variable_set(:@manager, manager)
        subject.tstring_end_update(2)
      end

      it 'removes the lineno to @tstring_nesting then calls @manager.start' do
        expect(manager).to receive(:actual_indentation)
        expect(manager).to receive(:start)
        subject.instance_variable_set(:@manager, manager)
        subject.instance_variable_set(:@tstring_nesting, [1])
        expect(subject).to receive(:measure)
        subject.tstring_end_update(2)
        expect(subject.instance_variable_get(:@tstring_nesting)).to be_empty
      end
    end
  end
end
