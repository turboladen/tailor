require 'spec_helper'
require 'tailor/configuration'
require 'tailor/cli'

describe Tailor::Configuration do
  before { allow(Tailor::Logger).to receive(:log) }

  subject do
    Tailor::Configuration.new('.')
  end

  describe '#formatters' do
    context 'param is nil' do
      it 'returns the pre-exisiting @formatters' do
        subject.instance_variable_set(:@formatters, [:blah])
        expect(subject.formatters).to eq [:blah]
      end
    end

    context 'param is some value' do
      it 'sets @formatters to that value' do
        subject.formatters 'blah'
        expect(subject.instance_variable_get(:@formatters)).to eq ['blah']
      end
    end
  end

  describe '#file_set' do
    before do
      subject.instance_variable_set(:@file_sets, {})
    end

    it 'adds the set of stuff to @file_sets' do
      subject.file_set('some_files', :bobo) do |style|
        style.trailing_newlines 2
      end

      expect(subject.instance_variable_get(:@file_sets)).to eq(
        bobo: {
          file_list: [],
          style: {
            allow_camel_case_methods: [false, { level: :error }],
            allow_conditional_parentheses: [false, { level: :warn }],
            allow_hard_tabs: [false, { level: :error }],
            allow_screaming_snake_case_classes: [false, { level: :error }],
            allow_trailing_line_spaces: [false, { level: :error }],
            allow_unnecessary_interpolation: [false, { level: :warn }],
            allow_invalid_ruby: [false, { level: :warn }],
            allow_unnecessary_double_quotes: [false, { level: :warn }],
            indentation_spaces: [2, { level: :error }],
            max_code_lines_in_class: [300, { level: :error }],
            max_code_lines_in_method: [30, { level: :error }],
            max_line_length: [80, { level: :error }],
            spaces_after_comma: [1, { level: :error }],
            spaces_after_conditional: [1, { level: :error }],
            spaces_after_lbrace: [1, { level: :error }],
            spaces_after_lbracket: [0, { level: :error }],
            spaces_after_lparen: [0, { level: :error }],
            spaces_before_comma: [0, { level: :error }],
            spaces_before_lbrace: [1, { level: :error }],
            spaces_before_rbrace: [1, { level: :error }],
            spaces_before_rbracket: [0, { level: :error }],
            spaces_before_rparen: [0, { level: :error }],
            spaces_in_empty_braces: [0, { level: :error }],
            trailing_newlines: [2, { level: :error }]
          }
        }
      )
    end

    context 'first param is nil' do
      it 'uses :default as the label' do
        subject.file_set
        expect(subject.instance_variable_get(:@file_sets)).to include(:default)
      end
    end
  end

  describe '#confg_file' do
    context '@config_file is already set' do
      it 'returns @config_file' do
        subject.instance_variable_set(:@config_file, 'pants')
        subject.config_file
        expect(subject.instance_variable_get(:@config_file)).to eq 'pants'
      end
    end

    context '@config_file is nil' do
      context 'DEFAULT_PROJECT_CONFIG exists' do
        before do
          expect(File).to receive(:exists?).with(/\.tailor/).and_return true
        end

        it "returns Dir.pwd + './tailor'" do
          subject.config_file
        end
      end

      context 'DEFAULT_PROJECT_CONFIG does not exist' do
        before do
          expect(File).to receive(:exists?).with(/\.tailor/).and_return false
          expect(File).to receive(:exists?).with(/\.tailorrc/).and_return true
        end

        it 'returns DEFAULT_RC_FILE' do
          subject.config_file
          expect(subject.instance_variable_get(:@config_file)).
            to eq Tailor::Configuration::DEFAULT_RC_FILE
        end
      end
    end
  end

  describe '#recursive_file_set' do
    before do
      subject.instance_variable_set(:@file_sets, {})
    end

    it 'yields if a block is provided' do
      expect do |config|
        subject.recursive_file_set('*.rb', &config)
      end.to yield_control
    end

    it 'does not raise if a block is not provided' do
      expect { subject.recursive_file_set('*.rb') }.not_to raise_error
    end
  end

  describe 'output file' do
    context 'defined' do
      subject do
        parser = Tailor::CLI::Options
        args = %w(--output-file=tailor-result.yaml)
        Tailor::Configuration.new(args, parser.parse!(args))
      end

      before { subject.load! }
      its(:output_file) { should eq 'tailor-result.yaml' }
    end

    context 'not defined' do
      its(:output_file) { should eq '' }
    end
  end
end
