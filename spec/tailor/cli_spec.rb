require_relative '../spec_helper'
require 'tailor/cli'


describe Tailor::CLI do
  let(:args) { [] }
  subject { Tailor::CLI.new(args)}

  describe "::run" do
    it "creates an instance of Tailor::CLI and calls that object's #execute!" do
      cli = double "Tailor::CLI"
      cli.should_receive(:execute!)
      Tailor::CLI.should_receive(:new).and_return cli
      Tailor::CLI.run({})
    end
  end

  describe "#initialize" do
    let(:args) { ['last'] }

    it "uses Options to parse the args" do
      config = double "Tailor::Configuration", style: [], formatters: []
      Tailor::Configuration.stub(:new).and_return config
      Tailor::Critic.stub(:new)
      Tailor::Reporter.stub(:new)
      Tailor::CLI::Options.should_receive(:parse!).with args

      Tailor::CLI.new(args)
    end

    it "creates a new Configuration from the file/dir and options" do
      Tailor::CLI::Options.stub(:parse!).and_return({})
      config = double "Tailor::Configuration", style: [], formatters: []
      Tailor::Configuration.should_receive(:new).with('last', {}).and_return config
      Tailor::Critic.stub(:new)

      Tailor::CLI.new(args)
    end
  end

  describe "#execute!" do
    let(:config) do
      config = double "Tailor::Configuration"
      config.stub(:style).and_return([])
      config.stub(:file_list).and_return(['one', 'two'])
      config.stub(:formatters).and_return(['text'])

      config
    end

    let(:reporter) do
      reporter = double "Tailor::Reporter"
      formatter = double "Tailor::Formatter::Faker"
      formatter.stub(:print_file_report)
      formatter.stub(:print_summary_report)
      formatter.stub(:each)
      reporter.stub(:formatters).and_return(formatter)

      reporter
    end

    let(:critic) do
      critic = double "Tailor::Critic"
      critic.stub(:problem_count).and_return(0)
      critic.should_receive(:check_file).twice

      critic
    end

    before do
      Tailor::CLI::Options.stub(:parse!).and_return({})
      Tailor::Configuration.stub(:new).and_return(config)
      Tailor::Critic.stub(:new).and_return(critic)
      Tailor::Reporter.stub(:new).and_return(reporter)
    end

    it "tells @critic to check each file" do
      subject.instance_variable_set(:@configuration, config)
      subject.instance_variable_set(:@critic, critic)
      subject.instance_variable_set(:@reporter, reporter)
      subject.execute!
    end
  end
end
