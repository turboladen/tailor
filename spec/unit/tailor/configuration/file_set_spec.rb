require 'spec_helper'
require 'tailor/configuration/file_set'

describe Tailor::Configuration::FileSet do
  describe '#build_file_list' do
    context 'param is a file name' do
      context 'the file exists' do
        before do
          FileUtils.touch './test.rb'
        end

        it 'builds an Array with that file\'s expanded path' do
          new_list = subject.instance_eval { build_file_list('./test.rb') }
          expect(new_list).to be_an Array
          expect(new_list.first).to match(%r{/test.rb$})
        end
      end

      context 'the file does not exist' do
        it 'returns an empty Array' do
          expect(subject.instance_eval { build_file_list('test.rb') }).to eq []
        end
      end
    end

    context 'when param is an Array' do
      before do
        FileUtils.touch './test.rb'
      end

      it 'returns the Array with expanded file paths' do
        expect(subject.instance_eval { build_file_list(['test.rb']) }.first).
          to match(%r{/test.rb$})
      end
    end

    context 'when param is a directory' do
      before do
        FileUtils.mkdir 'test'
        FileUtils.touch 'test/test.rb'
      end

      it 'returns the expanded file paths in that directory' do
        list = subject.instance_eval { build_file_list('test') }
        expect(list.size).to eq 1
        expect(list.first).to match(/.+\/test.rb/)
      end
    end
  end

  describe '#update_file_list' do
    before do
      subject.instance_variable_set(:@file_list, ['first.rb'])
      FileUtils.touch 'test2.rb'
    end

    it 'builds the file list and concats that to @file_list' do
      subject.update_file_list('test2.rb')
      expect(subject.instance_variable_get(:@file_list).size).to eq 2
      expect(subject.instance_variable_get(:@file_list).last).
        to match(%r{/test2.rb})
    end
  end
end
