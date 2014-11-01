require 'spec_helper'
require 'tailor/formatters/yaml'
require 'yaml'

describe Tailor::Formatters::Yaml do
  describe '#summary_report' do
    context 'no files have problems' do
      let(:problems) do
        {
          '/path_to/file1.rb' => [],
          '/path_to/file2.rb' => []
        }
      end

      it 'returns YAML with no body' do
        result = subject.summary_report(problems)
        hash = YAML.load(result)
        expect(hash).to eq({})
      end
    end

    context 'one file has one problem' do
      let(:problems) do
        {
          '/path_to/file1.rb' => [{
            type: 'type1', line: 23, column: 1,
            message: 'Some message', level: :error
          }],
          '/path_to/file2.rb' => []
        }
      end

      it 'returns YAML that contains the problem file and its problem' do
        result = subject.summary_report(problems)
        hash = YAML.load(result)
        expect(hash.keys.size).to eq 1
        expect(hash.keys.first).to eq '/path_to/file1.rb'
        expect(hash).to_not include '/path_to/file2.rb'
        expect(hash['/path_to/file1.rb'].first[:type]).to eq 'type1'
      end
    end

    context 'one file has one problem, another has two problems' do
      let(:problems) do
        {
          '/path_to/file1.rb' => [{
            type: 'type1', line: 23, column: 1,
            message: 'Some message', level: :error
          }],
          '/path_to/file2.rb' => [],
          '/path_to/file3.rb' => [{
            type: 'type2', line: 45, column: 1,
            message: 'file 3', level: :off
          }, {
            type: 'type3', line: 45, column: 2,
            message: 'file 3', level: :off
          }]
        }
      end

      it 'returns YAML that contains the problem files and their problems' do
        result = subject.summary_report(problems)
        hash = YAML.load(result)
        expect(hash.keys.size).to eq 2
        expect(hash.keys.first).to eq '/path_to/file1.rb'
        expect(hash.keys.last).to eq '/path_to/file3.rb'
        expect(hash).to_not include '/path_to/file2.rb'
        expect(hash['/path_to/file1.rb'].first[:type]).to eq 'type1'
        expect(hash['/path_to/file3.rb'].first[:type]).to eq 'type2'
        expect(hash['/path_to/file3.rb'].last[:type]).to eq 'type3'
      end
    end
  end
end
