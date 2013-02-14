require_relative '../../spec_helper'
require 'tailor/cli'


describe Tailor::CLI do
  let(:args) { [] }
  let(:options) { double "Options", show_config: false }

  let(:config) do
    double "Tailor::Configuration",
      file_sets: nil, formatters: nil, load!: nil
  end

  before do
    Tailor::Configuration.stub(:new).and_return config
    Tailor::Critic.stub(:new)
    Tailor::Reporter.stub(:new)
  end

  after do
    Tailor::Configuration.unstub(:new)
  end

  subject { Tailor::CLI.new(args) }

  describe "::run" do
    it "creates an instance of Tailor::CLI and calls that object's #execute!" do
      cli = double "Tailor::CLI"
      cli.should_receive(:execute!)
      Tailor::CLI.should_receive(:new).and_return cli
      Tailor::CLI.run([])
    end
  end

  describe "#initialize" do
    let(:args) { ['last'] }

    it "uses Options to parse the args" do
      Tailor::Configuration.stub(:new).and_return config
      Tailor::Critic.stub(:new)
      Tailor::Reporter.stub(:new)
      Tailor::CLI::Options.should_receive(:parse!).with(args).and_return options

      Tailor::CLI.new(args)
    end

    it "creates a new Configuration from the file/dir and options" do
      Tailor::CLI::Options.stub(:parse!).and_return(options)
      Tailor::Configuration.should_receive(:new).
        with(args, options).and_return config
      Tailor::Critic.stub(:new)

      Tailor::CLI.new(args)
    end

    context "options.show_config is true" do

    end

    context "options.show_config is false" do

    end
  end

  describe "#execute!" do
    let(:reporter) { double "Tailor::Reporter" }
    let(:critic) { double "Tailor::Critic", problem_count: 0 }

    before do
      Tailor::Critic.stub(:new).and_return(critic)
      Tailor::Reporter.stub(:new).and_return(reporter)
      subject.instance_variable_set(:@critic, critic)
      subject.instance_variable_set(:@reporter, reporter)
    end

    after do
      Tailor::Critic.unstub(:new)
      Tailor::Reporter.unstub(:new)
    end

    it "calls @critic.critique and yields file problems and the label" do
      problems_for_file = {}
      label = :test
      config.should_receive(:output_file)
      critic.stub(:problem_count).and_return 1
      critic.stub(:problems)
      critic.stub(:critique).and_yield(problems_for_file, label)
      reporter.stub(:summary_report)
      reporter.should_receive(:file_report).with(problems_for_file, label)

      subject.execute!
    end
  end

  describe "#result" do
    let(:critic) { double "Tailor::Critic", problem_count: 0 }

    before do
      Tailor::Critic.stub(:new).and_return(critic)
      subject.instance_variable_set(:@critic, critic)
    end

    after do
      Tailor::Critic.unstub(:new)
    end

    it "calls @critic.critique and return @critique.problems hash" do
      problems = {}
      critic.should_receive(:critique)
      critic.should_receive(:problems).and_return(problems)

      subject.result.should == problems
    end
  end
end
