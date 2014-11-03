require 'spec_helper'
require 'tailor/rake_task'

describe Tailor::RakeTask do
  let(:rake) do
    Rake::Application.new
  end

  before do
    FakeFS.deactivate!
    Rake.application = rake
  end

  describe 'rake tailor' do
    context 'with problematic files' do
      subject do
        Tailor::RakeTask.new do |t|
          t.config_file = File.expand_path 'spec/support/rake_task_config_problems.rb'
        end
      end

      it 'finds problems' do
        subject
        expect { rake['tailor'].invoke }.to raise_error SystemExit
      end
    end

    context 'with OK files' do
      subject do
        Tailor::RakeTask.new do |t|
          t.config_file = File.expand_path 'spec/support/rake_task_config_no_problems.rb'
        end
      end

      it 'does not find problems' do
        subject
        expect { rake['tailor'].invoke }.to_not raise_error
      end
    end
  end

  context 'using a custom task name' do
    subject do
      Tailor::RakeTask.new(task_name) do |t|
        t.config_file = File.expand_path 'spec/support/rake_task_config_problems.rb'
      end
    end

    let(:task_name) { 'my_neat_task' }

    it 'runs the task' do
      subject
      expect { rake[task_name].invoke }.to raise_exception SystemExit
    end
  end

  context 'overriding tailor opts within the task' do
    subject do
      Tailor::RakeTask.new do |t|
        t.config_file = File.expand_path 'spec/support/rake_task_config_problems.rb'
        t.tailor_opts = %w(--max-line-length=1000)
      end
    end

    it 'uses the options from the rake task' do
      subject
      expect { rake['tailor'].invoke }.to_not raise_error
    end
  end

  context 'adding file sets within the task' do
    let(:test_dir) do
      File.expand_path(File.dirname(__FILE__) + '/../dir')
    end

    before do
      require 'fileutils'

      FileUtils.mkdir(test_dir)  unless File.exist?(test_dir)
      expect(File.directory?(test_dir)).to eq true

      File.open(test_dir + '/test.rb', 'w') do |f|
        f.write <<-CONTENTS
puts 'I no have end quote
        CONTENTS
      end

      expect(File.exist?(test_dir + '/test.rb')).to eq true
    end

    after do
      FileUtils.rm_rf test_dir
    end

    subject do
      Tailor::RakeTask.new do |t|
        t.config_file = File.expand_path 'spec/support/rake_task_config_problems.rb'

        t.file_set('dir/**/*.rb', 'dir') do |style|
          style.max_line_length 1, level: :error
        end
      end
    end

    it 'uses the options from the rake task' do
      subject
      expect { rake['tailor'].invoke }.to raise_error
    end
  end
end
