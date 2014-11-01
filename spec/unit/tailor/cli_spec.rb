require 'spec_helper'
require 'tailor/cli'

describe Tailor::CLI do
  let(:args) { [] }
  let(:options) { double 'Options', show_config: false }

  let(:config) do
    double 'Tailor::Configuration', file_sets: nil, formatters: nil, load!: nil
  end

  before do
    allow(Tailor::Configuration).to receive(:new).and_return config
    allow(Tailor::Critic).to receive(:new)
    allow(Tailor::Reporter).to receive(:new)
  end

  subject { Tailor::CLI.new(args) }

  describe '::run' do
    it "creates an instance of Tailor::CLI and calls that object's #execute!" do
      cli = double 'Tailor::CLI'
      expect(cli).to receive(:execute!)
      expect(Tailor::CLI).to receive(:new).and_return cli
      Tailor::CLI.run([])
    end
  end

  describe '#initialize' do
    let(:args) { %w(last) }

    it 'uses Options to parse the args' do
      allow(Tailor::Configuration).to receive(:new).and_return config
      allow(Tailor::Critic).to receive(:new)
      allow(Tailor::Reporter).to receive(:new)
      expect(Tailor::CLI::Options).to receive(:parse!).
        with(args).and_return options

      Tailor::CLI.new(args)
    end

    it 'creates a new Configuration from the file/dir and options' do
      allow(Tailor::CLI::Options).to receive(:parse!).and_return(options)
      expect(Tailor::Configuration).to receive(:new).with(args, options).
        and_return config
      Tailor::Critic.stub(:new)

      Tailor::CLI.new(args)
    end

    context 'options.show_config is true' do
      pending
    end

    context 'options.show_config is false' do
      pending
    end
  end

  describe '#execute!' do
    let(:reporter) { double 'Tailor::Reporter' }
    let(:critic) { double 'Tailor::Critic', problem_count: 0 }

    before do
      allow(Tailor::Critic).to receive(:new).and_return(critic)
      allow(Tailor::Reporter).to receive(:new).and_return(reporter)
      subject.instance_variable_set(:@critic, critic)
      subject.instance_variable_set(:@reporter, reporter)
    end

    it 'calls @critic.critique and yields file problems and the label' do
      problems_for_file = {}
      label = :test
      expect(config).to receive(:output_file)
      allow(critic).to receive(:problem_count).and_return 1
      allow(critic).to receive(:problems)
      allow(critic).to receive(:critique).and_yield(problems_for_file, label)
      allow(reporter).to receive(:summary_report)
      expect(reporter).to receive(:file_report).with(problems_for_file, label)

      subject.execute!
    end
  end

  describe '#result' do
    let(:critic) { double 'Tailor::Critic', problem_count: 0 }

    before do
      allow(Tailor::Critic).to receive(:new).and_return(critic)
      subject.instance_variable_set(:@critic, critic)
    end

    it 'calls @critic.critique and return @critique.problems hash' do
      problems = {}
      expect(critic).to receive(:critique)
      expect(critic).to receive(:problems).and_return(problems)

      expect(subject.result).to eq problems
    end
  end
end
