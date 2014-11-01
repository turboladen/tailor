require 'spec_helper'
require 'tailor/formatter'

describe Tailor::Formatter do
  describe '#problems_at_level' do
    let(:problems) do
      msg = 'File contains invalid Ruby; '
      msg << 'run `ruby -c [your_file.rb]` for more details.'

      {
        'some_file.rb' => [
          {
            type: 'allow_invalid_ruby',
            line: 0,
            column: 0,
            message: msg,
            level: :warn
          }
        ]
      }
    end

    context 'problems are empty' do
      it 'returns an empty Array' do
        expect(subject.problems_at_level({}, :error)).to eq []
      end
    end

    context 'the level asked for exists in the problems' do
      it 'returns the problem' do
        msg = 'File contains invalid Ruby; '
        msg << 'run `ruby -c [your_file.rb]` for more details.'

        expect(subject.problems_at_level(problems, :warn)).to eq [
          {
            type: 'allow_invalid_ruby',
            line: 0,
            column: 0,
            message: msg,
            level: :warn
          }
        ]
      end
    end

    context 'the level asked for does not exist in the problems' do
      it 'returns an empty Array' do
        expect(subject.problems_at_level(problems, :error)).to eq []
      end
    end
  end
end
