require 'spec_helper'
require 'tailor/rulers/spaces_after_comma_ruler'

describe Tailor::Rulers::SpacesAfterCommaRuler do
  subject { Tailor::Rulers::SpacesAfterCommaRuler.new(nil, {}) }

  describe '#comma_update' do
    it 'adds the column number to @comma_columns' do
      subject.comma_update(',', 2, 1)
      expect(subject.instance_variable_get(:@comma_columns)).to eq [1]
    end
  end

  describe '#check_spaces_after_comma' do
    context 'no event after comma' do
      let(:lexed_line) do
        l = double 'LexedLine'
        allow(l).to receive(:event_at)
        allow(l).to receive(:index)

        l
      end

      it 'does not detect any problems' do
        expect(Tailor::Problem).to_not receive(:new)
        expect { subject.check_spaces_after_comma(lexed_line, 1) }.
          to_not raise_error
      end
    end
  end
end
