require 'spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'

#-------------------------------------------------------------------------------
# Hard tabs
#-------------------------------------------------------------------------------
HARD_TABS = {}

HARD_TABS['hard_tab'] =
  %(def something
\tputs 'something'
end)

HARD_TABS['hard_tab_with_spaces'] =
  %(class Thing
  def something
\t  puts 'something'
  end
end)

# This only reports the hard tab problem (and not the indentation problem)
# because a hard tab is counted as 1 space; here, this is 4 spaces, so it
# looks correct to the parser.  I'm leaving this behavior, as detecting the
# hard tab should signal the problem.  If you fix the hard tab and don't
# fix indentation, tailor will flag you on the indentation on the next run.
HARD_TABS['hard_tab_with_1_indented_space'] =
  %(class Thing
  def something
\t   puts 'something'
  end
end)

HARD_TABS['hard_tab_with_2_indented_spaces'] =
  %(class Thing
  def something
\t    puts 'something'
  end
end)

describe 'Hard tab detection' do
  before do
    allow(Tailor::Logger).to receive(:log)
    FakeFS.activate!
    File.open(file_name, 'w') { |f| f.write contents }
    critic.check_file(file_name, style.to_hash)
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:contents) { HARD_TABS[file_name] }

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  context '1 hard tab' do
    let(:file_name) { 'hard_tab' }
    specify { expect(critic.problems[file_name].size).to eq 2 }
    specify { expect(critic.problems[file_name].first[:type]).to eq 'allow_hard_tabs' }
    specify { expect(critic.problems[file_name].first[:line]).to eq 2 }
    specify { expect(critic.problems[file_name].first[:column]).to eq 0 }
    specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    specify { expect(critic.problems[file_name].last[:type]).to eq 'indentation_spaces' }
    specify { expect(critic.problems[file_name].last[:line]).to eq 2 }
    specify { expect(critic.problems[file_name].last[:column]).to eq 1 }
    specify { expect(critic.problems[file_name].last[:level]).to eq :error }
  end

  context '1 hard tab with 2 spaces after it' do
    let(:file_name) { 'hard_tab_with_spaces' }
    specify { expect(critic.problems[file_name].size).to eq 2 }
    specify { expect(critic.problems[file_name].first[:type]).to eq 'allow_hard_tabs' }
    specify { expect(critic.problems[file_name].first[:line]).to eq 3 }
    specify { expect(critic.problems[file_name].first[:column]).to eq 0 }
    specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    specify { expect(critic.problems[file_name].last[:type]).to eq 'indentation_spaces' }
    specify { expect(critic.problems[file_name].last[:line]).to eq 3 }
    specify { expect(critic.problems[file_name].last[:column]).to eq 3 }
    specify { expect(critic.problems[file_name].last[:level]).to eq :error }
  end

  context '1 hard tab with 3 spaces after it' do
    let(:file_name) { 'hard_tab_with_1_indented_space' }
    specify { expect(critic.problems[file_name].size).to eq 1 }
    specify { expect(critic.problems[file_name].first[:type]).to eq 'allow_hard_tabs' }
    specify { expect(critic.problems[file_name].first[:line]).to eq 3 }
    specify { expect(critic.problems[file_name].first[:column]).to eq 0 }
    specify { expect(critic.problems[file_name].first[:level]).to eq :error }
  end

  context '1 hard tab with 4 spaces after it' do
    let(:file_name) { 'hard_tab_with_2_indented_spaces' }
    specify { expect(critic.problems[file_name].size).to eq 2 }
    specify { expect(critic.problems[file_name].first[:type]).to eq 'allow_hard_tabs' }
    specify { expect(critic.problems[file_name].first[:line]).to eq 3 }
    specify { expect(critic.problems[file_name].first[:column]).to eq 0 }
    specify { expect(critic.problems[file_name].first[:level]).to eq :error }
    specify { expect(critic.problems[file_name].last[:type]).to eq 'indentation_spaces' }
    specify { expect(critic.problems[file_name].last[:line]).to eq 3 }
    specify { expect(critic.problems[file_name].last[:column]).to eq 5 }
    specify { expect(critic.problems[file_name].last[:level]).to eq :error }
  end
end
