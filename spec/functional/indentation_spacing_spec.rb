require 'spec_helper'
require_relative '../support/good_indentation_cases'
require 'tailor/critic'
require 'tailor/configuration/style'

describe 'Indentation spacing problem detection' do
  before do
    allow(Tailor::Logger).to receive(:log)
    FakeFS.activate!
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  let(:contents) { INDENT_1[file_name] }

  INDENT_OK.each do |file_name, contents|
    before do
      FileUtils.touch file_name
      File.open(file_name, 'w') { |f| f.write contents }
    end

    it 'is OK' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems).to eq(file_name =>  [])
    end
  end

  context 'case statement with indented whens' do
    let(:file_name) { 'case_whens_in' }

    let(:contents) do
      %(def my_method
  case true
    when true
      puts "stuff"
    when false
      puts "blah blah"
  end
end)
    end

    it 'is OK' do
      skip 'Implementation of the option to allow for this'
    end
  end

  context 'method with rparen on following line' do
    let(:file_name) { 'method_closing_lonely_paren' }

    let(:contents) do
      %{def your_thing(one
  )
end}
    end

    it 'is OK' do
      skip 'Implementation'
    end
  end

  context 'lonely rparen and do on the same line' do
    let(:file_name) { 'rparen_and_do_same_line' }

    let(:contents) do
      %{opt.on('-c', '--config-file FILE',
  "Use a specific config file.") do |config|
  options.config_file = config
end}
    end

    it 'is OK' do
      skip 'Implementation'
    end
  end

  context 'block chained on a block' do
    let(:file_name) { 'block_chain' }

    let(:contents) do
      %({
  a: 1
}.each do |k, v|
  puts k, v
end)
    end

    it 'is OK' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems).to eq(file_name =>  [])
    end
  end
end
