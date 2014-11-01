require 'spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'

METHOD_LENGTH = {}
METHOD_LENGTH['method_too_long'] =
  %(def thing
  puts
  puts
end)

METHOD_LENGTH['parent_method_too_long'] =
  %(def thing
  puts
  def inner_thing; print '1'; end
  puts
end)

describe 'Detection of method length' do
  before do
    allow(Tailor::Logger).to receive(:log)
    FakeFS.activate!
    File.open(file_name, 'w') { |f| f.write contents }
    critic.check_file(file_name, style.to_hash)
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:contents) { METHOD_LENGTH[file_name] }

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off
    style.max_code_lines_in_method 3

    style
  end

  context 'single class too long' do
    let(:file_name) { 'method_too_long' }
    specify { expect(critic.problems[file_name].size).to eq 1 }
    specify { expect(critic.problems[file_name].first[:type]).to eq 'max_code_lines_in_method' }
    specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
    specify { expect(critic.problems[file_name].first[:column]).to eq 0 }
    specify { expect(critic.problems[file_name].first[:level]).to eq :error }
  end

  context 'method in a method' do
    let(:file_name) { 'method_too_long' }
    specify { expect(critic.problems[file_name].size).to eq 1 }
    specify { expect(critic.problems[file_name].first[:type]).to eq 'max_code_lines_in_method' }
    specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
    specify { expect(critic.problems[file_name].first[:column]).to eq 0 }
    specify { expect(critic.problems[file_name].first[:level]).to eq :error }
  end
end
