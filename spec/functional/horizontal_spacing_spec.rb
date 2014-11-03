require 'spec_helper'
require_relative '../support/horizontal_spacing_cases'
require 'tailor/critic'
require 'tailor/configuration/style'

describe 'Horizontal Space problem detection' do
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

  H_SPACING_OK.each do |file_name, contents|
    before do
      FileUtils.touch file_name
      File.open(file_name, 'w') { |f| f.write contents }
    end

    it 'is OK' do
      critic.check_file(file_name, style.to_hash)
      expect(critic.problems).to eq(file_name =>  [])
    end
  end

  context 'line ends with a backslash' do
    let(:file_name) { 'line_split_by_backslash' }

    before do
      FileUtils.touch file_name
      File.open(file_name, 'w') { |f| f.write contents }
    end

    context 'no problems' do
      let(:contents) do
        %(execute 'myscript' do
  command \\
    '/some/line/that/is/not/over/eighty/chars.sh'
  only_if { something }
end)
      end

      it 'is OK' do
        critic.check_file(file_name, style.to_hash)
        expect(critic.problems).to eq(file_name => [])
      end
    end

    context 'line after backslash is too long' do
      let(:contents) do
        %(execute 'myscript' do
  command \\
    '#{'*' * 75}'
  only_if { something }
end)
      end

      it 'is OK' do
        critic.check_file(file_name, style.to_hash)
        expect(critic.problems).to eq(
          file_name => [
            {
              type: 'max_line_length',
              line: 3,
              column: 81,
              message: 'Line is 81 chars long, but should be 80.',
              level: :error
            }
          ])
      end
    end
  end
end
