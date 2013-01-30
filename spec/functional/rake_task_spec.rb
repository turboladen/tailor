require "spec_helper"
require "tailor/rake_task"


describe Tailor::RakeTask do
  let(:rake) do
    Rake::Application.new
  end

  before do
    FakeFS.deactivate!
    Rake.application = rake
  end

  describe 'rake tailor' do
    context "with problematic files" do
      subject do
        Tailor::RakeTask.new do |t|
          t.config_file = File.expand_path 'spec/support/rake_task_config_problems.rb'
        end
      end

      it "finds problems" do
        subject

        expect {
          rake['tailor'].invoke
        }.to raise_error SystemExit
      end
    end

    context "with OK files" do
      subject do
        Tailor::RakeTask.new do |t|
          t.config_file = File.expand_path 'spec/support/rake_task_config_no_problems.rb'
        end
      end

      it "doesn't find problems" do
        subject

        expect {
          rake['tailor'].invoke
        }.to_not raise_error
      end
    end
  end

  context "using a custom task name" do
    subject do
      Tailor::RakeTask.new(task_name) do |t|
        t.config_file = File.expand_path 'spec/support/rake_task_config_problems.rb'
      end
    end

    let(:task_name) { 'my_neat_task' }

    it "runs the task" do
      subject

      expect {
        rake[task_name].invoke
      }.to_not raise_error RuntimeError, "Don't know how to build task '#{task_name}''"
    end
  end

  context "overriding tailor opts within the task" do
    subject do
      Tailor::RakeTask.new do |t|
        t.config_file = File.expand_path 'spec/support/rake_task_config_problems.rb'
        t.tailor_opts = %w[--max-line-length=1000]
      end
    end

    it "uses the options from the rake task" do
      subject

      expect {
        rake['tailor'].invoke
      }.to_not raise_error
    end
  end
end
