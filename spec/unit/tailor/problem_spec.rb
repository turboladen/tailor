require 'spec_helper'
require 'tailor/problem'

describe Tailor::Problem do
  before do
    Tailor::Problem.any_instance.stub(:log)
  end

  let(:lineno) { 10 }
  let(:column) { 11 }

  describe '#set_values' do
    before do
      Tailor::Problem.any_instance.stub(:message)
    end

    it 'sets self[:type] to the type param' do
      Tailor::Problem.new(:test, lineno, column, '', :b).
        should include(type: :test)
    end

    it 'sets self[:line] to the lineno param' do
      Tailor::Problem.new(:test, lineno, column, '', :c).
        should include(line: lineno)
    end

    it 'sets self[:column] to the column param' do
      Tailor::Problem.new(:test, lineno, column, '', :d).
        should include(column: column)
    end

    it 'sets self[:message] to the message param' do
      Tailor::Problem.new(:test, lineno, column, 'test', :d).
        should include(message: 'test')
    end

    it 'sets self[:level] to the level param' do
      Tailor::Problem.new(:test, lineno, column, 'test', :d).
        should include(level: :d)
    end
  end
end
