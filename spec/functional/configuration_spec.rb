require 'spec_helper'
require 'tailor/configuration'


describe 'Config File' do
  before do
    Tailor::Logger.stub(:log)
    FakeFS.deactivate!
  end

  after do
    FakeFS.activate!
  end

  context 'files are not given at runtime' do
    let(:config) do
      config = Tailor::Configuration.new
      config.load!

      config
    end

    context '.tailor does not exist' do
      before do
        Tailor::Configuration.any_instance.stub(:config_file).and_return false
      end

      it "sets formatters to 'text'" do
        config.formatters.should == %w(text)
      end

      it 'sets file_sets[:default].style to the default style' do
        config.file_sets[:default].style.should_not be_nil
        config.file_sets[:default].style.should == Tailor::Configuration::Style.new.to_hash
      end

      it 'sets file_sets[:default].file_list to the files in lib/**/*.rb' do
        config.file_sets[:default].file_list.all? do |path|
          path =~ /tailor\/lib/
        end.should be_true
      end
    end

    context '.tailor defines the default file set' do
      context 'and another file set' do
        let(:config_file) do
          <<-CONFIG
Tailor.config do |config|
  config.file_set 'lib/**/*.rb'

  config.file_set 'features/**/*.rb', :features do |style|
    style.max_line_length 90, level: :warn
  end
end
          CONFIG
        end

        before do
          File.should_receive(:read).and_return config_file
        end

        it 'creates the default file set' do
          config.file_sets[:default].style.should == Tailor::Configuration::Style.new.to_hash
          config.file_sets[:default].file_list.all? do |path|
            path =~ /tailor\/lib/
          end.should be_true
        end

        it 'creates the :features file set' do
          style = Tailor::Configuration::Style.new
          style.max_line_length(90, level: :warn)
          config.file_sets[:features].style.should == style.to_hash
          config.file_sets[:features].file_list.all? do |path|
            path =~ /features/
          end.should be_true
        end
      end
    end

    context '.tailor defines NO default file set' do
      let(:config_file) do
        <<-CONFIG
Tailor.config do |config|
  config.file_set 'features/**/*.rb', :features do |style|
    style.max_line_length 90, level: :warn
  end
end
        CONFIG
      end

      before do
        File.should_receive(:read).and_return config_file
      end

      it 'does not create a :default file set' do
        config.file_sets.should_not include :default
      end

      it 'creates the non-default file set' do
        config.file_sets.should include :features
      end
    end

    context '.tailor defines a single recursive file set' do
      let(:config_file) do
        <<-CONFIG
Tailor.config do |config|
  config.recursive_file_set '*spec.rb' do |style|
    style.max_line_length 90, level: :warn
  end
end
        CONFIG
      end

      before do
        File.should_receive(:read).and_return config_file
      end

      it 'creates a :default file set' do
        config.file_sets.keys.should == [:default]
      end

      it 'has files in the file list levels deep' do
        config.file_sets[:default].file_list.all? do |file|
          file =~ /spec\.rb$/
        end.should be_true
      end

      it 'applies the nested configuration within the fileset' do
        expect(config.file_sets[:default].style[
          :max_line_length]).to eql [90, { :level => :warn }]
      end

    end
  end

  context 'files are given at runtime' do
    let(:config) do
      config = Tailor::Configuration.new('lib/tailor.rb')
      config.load!

      config
    end

    context '.tailor does not exist' do
      before do
        Tailor::Configuration.any_instance.stub(:config_file).and_return false
      end

      it "sets formatters to 'text'" do
        config.formatters.should == %w(text)
      end

      it 'sets file_sets[:default].style to the default style' do
        config.file_sets[:default].style.should_not be_nil
        config.file_sets[:default].style.should == Tailor::Configuration::Style.new.to_hash
      end

      it 'sets file_sets[:default].file_list to the runtime files' do
        config.file_sets[:default].file_list.size.should be 1
        config.file_sets[:default].file_list.first.match /lib\/tailor\.rb$/
      end
    end

    context '.tailor defines the default file set' do
      context 'and another file set' do
        let(:config_file) do
          <<-CONFIG
Tailor.config do |config|
  config.file_set 'lib/**/*.rb' do |style|
    style.max_line_length 85
  end

  config.file_set 'features/**/*.rb', :features do |style|
    style.max_line_length 90, level: :warn
  end
end
          CONFIG
        end

        before do
          File.should_receive(:read).and_return config_file
        end

        it 'creates the default file set using the runtime files' do
          style = Tailor::Configuration::Style.new
          style.max_line_length 85
          config.file_sets[:default].style.should == style.to_hash
          config.file_sets[:default].file_list.size.should be 1
          config.file_sets[:default].file_list.first.match /lib\/tailor\.rb$/
        end

        it 'does not create the :features file set' do
          config.file_sets.should_not include :features
        end
      end
    end

    context '.tailor defines NO default file set' do
      let(:config_file) do
        <<-CONFIG
Tailor.config do |config|
  config.file_set 'features/**/*.rb', :features do |style|
    style.max_line_length 90, level: :warn
  end
end
        CONFIG
      end

      before do
        File.should_receive(:read).and_return config_file
      end

      it 'creates a :default file set with the runtime file and default style' do
        config.file_sets[:default].style.should == Tailor::Configuration::Style.new.to_hash
        config.file_sets[:default].file_list.size.should be 1
        config.file_sets[:default].file_list.first.match /lib\/tailor\.rb$/
      end

      it 'does not create the non-default file set' do
        config.file_sets.should_not include :features
      end
    end

    context '.tailor defines a single recursive file set' do
      let(:config_file) do
        <<-CONFIG
Tailor.config do |config|
  config.recursive_file_set '*_spec.rb' do |style|
    style.max_line_length 90, level: :warn
  end
end
        CONFIG
      end

      before do
        File.should_receive(:read).and_return config_file
      end

      it 'creates a :default file set' do
        config.file_sets.keys.should == [:default]
      end

      it 'creates a :default file set with the runtime file and default style' do
        style = Tailor::Configuration::Style.new.tap do |style|
          style.max_line_length 90, level: :warn
        end.to_hash
        config.file_sets[:default].style.should == style
        config.file_sets[:default].file_list.size.should be 1
        config.file_sets[:default].file_list.first.match /lib\/tailor\.rb$/
      end
    end

    context '.tailor defines a yaml formatter' do
      let(:config_file) do
        <<-CONFIG
Tailor.config do |config|
  config.formatters 'yaml'
end
        CONFIG
      end

      before do
        File.should_receive(:read).and_return config_file
      end

      it "sets formatters to 'yaml'" do
        config.formatters.should == %w(yaml)
      end
    end

    context '.tailor defines a more than one formatter' do
      let(:config_file) do
        <<-CONFIG
Tailor.config do |config|
  config.formatters 'yaml', 'text'
end
        CONFIG
      end

      before do
        File.should_receive(:read).and_return config_file
      end

      it 'sets formatters to the defined' do
        config.formatters.should == %w(yaml text)
      end

    end
  end
end
