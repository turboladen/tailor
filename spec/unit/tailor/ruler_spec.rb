require 'spec_helper'
require 'tailor/ruler'

describe Tailor::Ruler do
  before { allow(Tailor::Logger).to receive(:log) }

  describe '#add_child_ruler' do
    it 'adds new rulers to @child_rulers' do
      ruler = double 'Ruler'
      subject.add_child_ruler(ruler)
      expect(subject.instance_variable_get(:@child_rulers).first).to eq ruler
    end
  end

  describe '#problems' do
    context 'no child_rulers' do
      context '@problems is empty' do
        specify { expect(subject.problems).to be_empty }
      end

      context '@problems.size is 1' do
        before do
          problem = double 'Problem'
          expect(problem).to receive(:[]).with :line
          subject.instance_variable_set(:@problems, [problem])
        end

        specify { expect(subject.problems.size).to eq 1 }
      end
    end

    context 'child_rulers have problems' do
      before do
        problem = double 'Problem'
        expect(problem).to receive(:[]).with :line
        child_ruler = double 'Ruler'
        allow(child_ruler).to receive(:problems).and_return([problem])
        subject.instance_variable_set(:@child_rulers, [child_ruler])
      end

      context '@problems is empty' do
        specify { expect(subject.problems.size).to eq 1 }
      end

      context '@problems.size is 1' do
        before do
          problem = double 'Problem'
          expect(problem).to receive(:[]).with :line
          subject.instance_variable_set(:@problems, [problem])
        end

        specify { expect(subject.problems.size).to eq 2 }
      end
    end
  end
end
