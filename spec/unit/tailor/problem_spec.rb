require 'spec_helper'
require 'tailor/problem'

describe Tailor::Problem do
  before do
    allow_any_instance_of(Tailor::Problem).to receive(:log)
  end

  let(:lineno) { 10 }
  let(:column) { 11 }

  describe '#set_values' do
    before do
      allow_any_instance_of(Tailor::Problem).to receive(:message)
    end

    it 'sets self[:type] to the type param' do
      expect(Tailor::Problem.new(:test, lineno, column, '', :b)).
        to include(type: :test)
    end

    it 'sets self[:line] to the lineno param' do
      expect(Tailor::Problem.new(:test, lineno, column, '', :c)).
        to include(line: lineno)
    end

    it 'sets self[:column] to the column param' do
      expect(Tailor::Problem.new(:test, lineno, column, '', :d)).
        to include(column: column)
    end

    it 'sets self[:message] to the message param' do
      expect(Tailor::Problem.new(:test, lineno, column, 'test', :d)).
        to include(message: 'test')
    end

    it 'sets self[:level] to the level param' do
      expect(Tailor::Problem.new(:test, lineno, column, 'test', :d)).
        to include(level: :d)
    end
  end
end
