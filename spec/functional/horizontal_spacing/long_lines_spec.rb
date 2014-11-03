require 'spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'

LONG_LINE = {}
LONG_LINE['long_line_no_newline'] = %('#{'#' * 79}')
LONG_LINE['long_line_newline_at_82'] = %('#{'#' * 79}'
)

describe 'Long line detection' do
  before do
    allow(Tailor::Logger).to receive(:log)
    FakeFS.activate!
    File.open(file_name, 'w') { |f| f.write contents }
    critic.check_file(file_name, style.to_hash)
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:contents) { LONG_LINE[file_name] }

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  context 'line is 81 chars, no newline' do
    let(:file_name) { 'long_line_no_newline' }
    specify { expect(critic.problems[file_name].size).to eq 1 }
    specify { expect(critic.problems[file_name].first[:type]).to eq 'max_line_length' }
    specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
    specify { expect(critic.problems[file_name].first[:column]).to eq 81 }
    specify { expect(critic.problems[file_name].first[:level]).to eq :error }
  end

  context 'line is 81 chars, plus a newline' do
    let(:file_name) { 'long_line_newline_at_82' }
    specify { expect(critic.problems[file_name].size).to eq 1 }
    specify { expect(critic.problems[file_name].first[:type]).to eq 'max_line_length' }
    specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
    specify { expect(critic.problems[file_name].first[:column]).to eq 81 }
    specify { expect(critic.problems[file_name].first[:level]).to eq :error }
  end
end
