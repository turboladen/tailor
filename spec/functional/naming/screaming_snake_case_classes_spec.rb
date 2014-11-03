require 'spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'

SCREAMING_SNAKE_CASE_CLASSES = {}

SCREAMING_SNAKE_CASE_CLASSES['one_screaming_snake_case_class'] =
  %(class Thing_One
end)

SCREAMING_SNAKE_CASE_CLASSES['one_screaming_snake_case_module'] =
  %(module Thing_One
end)

SCREAMING_SNAKE_CASE_CLASSES['double_screaming_snake_case_class'] =
  %(class Thing_One_Again
end)

SCREAMING_SNAKE_CASE_CLASSES['double_screaming_snake_case_module'] =
  %(module Thing_One_Again
end)

describe 'Detection of camel case methods' do
  before do
    Tailor::Logger.stub(:log)
    FakeFS.activate!
    File.open(file_name, 'w') { |f| f.write contents }
    critic.check_file(file_name, style.to_hash)
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:contents) { SCREAMING_SNAKE_CASE_CLASSES[file_name] }

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  context 'standard screaming snake case class' do
    let(:file_name) { 'one_screaming_snake_case_class' }
    specify { expect(critic.problems[file_name].size).to eq 1 }
    specify { expect(critic.problems[file_name].first[:type]).to eq 'allow_screaming_snake_case_classes' }
    specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
    specify { expect(critic.problems[file_name].first[:column]).to eq 6 }
    specify { expect(critic.problems[file_name].first[:level]).to eq :error }
  end

  context 'standard screaming snake case module' do
    let(:file_name) { 'one_screaming_snake_case_module' }
    specify { expect(critic.problems[file_name].size).to eq 1 }
    specify { expect(critic.problems[file_name].first[:type]).to eq 'allow_screaming_snake_case_classes' }
    specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
    specify { expect(critic.problems[file_name].first[:column]).to eq 7 }
    specify { expect(critic.problems[file_name].first[:level]).to eq :error }
  end

  context 'double screaming snake case class' do
    let(:file_name) { 'double_screaming_snake_case_class' }
    specify { expect(critic.problems[file_name].size).to eq 1 }
    specify { expect(critic.problems[file_name].first[:type]).to eq 'allow_screaming_snake_case_classes' }
    specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
    specify { expect(critic.problems[file_name].first[:column]).to eq 6 }
    specify { expect(critic.problems[file_name].first[:level]).to eq :error }
  end

  context 'double screaming snake case module' do
    let(:file_name) { 'double_screaming_snake_case_module' }
    specify { expect(critic.problems[file_name].size).to eq 1 }
    specify { expect(critic.problems[file_name].first[:type]).to eq 'allow_screaming_snake_case_classes' }
    specify { expect(critic.problems[file_name].first[:line]).to eq 1 }
    specify { expect(critic.problems[file_name].first[:column]).to eq 7 }
    specify { expect(critic.problems[file_name].first[:level]).to eq :error }
  end
end
