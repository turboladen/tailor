require_relative '../../../spec_helper'
require 'tailor/formatters/yaml'
require 'yaml'


describe Tailor::Formatters::YAML do
  describe '#summary_report' do
    let(:problems) do
      {
        '/path_to/file1.rb' => [{
          type: 'type1', line: 23, column: 1,
          message: 'Some message', level: :error
        }],
        '/path_to/file2.rb' => [{
          type: 'type2', line: 23, column: 1,
          message: 'Some message', level: :error
        }],
        '/path_to/file3.rb' => [{
          type: 'type3', line: 23, column: 1,
          message: 'Some message', level: :error
        }],
        'path_to/file4.rb' => []
      }
    end

    it 'should return problems as yaml' do
      result = subject.summary_report(problems)
      hash = YAML.load(result)
      hash.keys.size.should == 3
      hash.keys.first.should == '/path_to/file1.rb'
      hash.has_key?('/path_to/file4.rb').should be_false
      hash['/path_to/file2.rb'].first[:type].should eq 'type2'
    end
  end
end
