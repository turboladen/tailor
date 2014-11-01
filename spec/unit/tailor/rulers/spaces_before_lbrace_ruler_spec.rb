require 'spec_helper'
require 'tailor/rulers/spaces_before_lbrace_ruler'

describe Tailor::Rulers::SpacesBeforeLbraceRuler do
  subject { Tailor::Rulers::SpacesBeforeLbraceRuler.new(nil, {}) }
  before { Tailor::Logger.stub(:log) }

  describe '#count_spaces' do
    context 'lexed_line.event_index is 0' do
      let(:lexed_line) do
        l = double 'LexedLine'
        l.stub(:event_index).and_return 0
        l.stub(:at).and_return nil

        l
      end

      specify { expect(subject.count_spaces(lexed_line, 1)).to be_zero }

      it 'sets @do_measurement to false' do
        expect { subject.count_spaces(lexed_line, 1) }.
          to change { subject.instance_variable_get(:@do_measurement) }.
          from(true).to(false)
      end
    end

    context 'no space before lbrace' do
      let(:lexed_line) do
        l = double 'LexedLine'
        l.stub(:event_index).and_return 1
        l.stub(:at).and_return [[10, 0], :on_const, 'HI']

        l
      end

      specify { expect(subject.count_spaces(lexed_line, 1)).to be_zero }
    end

    context '1 space before lbrace' do
      let(:lexed_line) do
        l = double 'LexedLine'
        l.stub(:event_index).and_return 1
        l.stub(:at).and_return [[10, 0], :on_sp, ' ']

        l
      end

      specify { expect(subject.count_spaces(lexed_line, 1)).to eq 1 }
    end

    context '> 1 space before lbrace' do
      let(:lexed_line) do
        l = double 'LexedLine'
        l.stub(:event_index).and_return 1
        l.stub(:at).and_return [[10, 1], :on_sp, '  ']

        l
      end

      specify { expect(subject.count_spaces(lexed_line, 3)).to eq 2 }
    end
  end
end
