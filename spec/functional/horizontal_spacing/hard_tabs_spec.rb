require_relative '../../spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'

#-------------------------------------------------------------------------------
# Hard tabs
#-------------------------------------------------------------------------------
HARD_TABS = {}

HARD_TABS[:hard_tab] =
  %Q{def something
\tputs "something"
end}

HARD_TABS[:hard_tab_with_spaces] =
  %Q{class Thing
  def something
\t  puts "something"
  end
end}

# This only reports the hard tab problem (and not the indentation problem)
# because a hard tab is counted as 1 space; here, this is 4 spaces, so it
# looks correct to the parser.  I'm leaving this behavior, as detecting the
# hard tab should signal the problem.  If you fix the hard tab and don't
# fix indentation, tailor will flag you on the indentation on the next run.
HARD_TABS[:hard_tab_with_1_indented_space] =
  %Q{class Thing
  def something
\t   puts "something"
  end
end}

HARD_TABS[:hard_tab_with_2_indented_spaces] =
  %Q{class Thing
  def something
\t    puts "something"
  end
end}

describe "Hard tab detection" do
  before do
    Tailor::Logger.stub(:log)
    FakeFS.activate!
    File.open(file_name.to_s, 'w') { |f| f.write contents }
    critic.check_file(file_name.to_s, style.to_hash)
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:contents) { HARD_TABS[file_name]}

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  context "1 hard tab" do
    let(:file_name) { :hard_tab }
    specify { critic.problems[file_name.to_s].size.should be 2 }
    specify { critic.problems[file_name.to_s].first[:type].should == "allow_hard_tabs"  }
    specify { critic.problems[file_name.to_s].first[:line].should be 2 }
    specify { critic.problems[file_name.to_s].first[:column].should be 0 }
    specify { critic.problems[file_name.to_s].first[:level].should be :error }
    specify { critic.problems[file_name.to_s].last[:type].should == "indentation_spaces"  }
    specify { critic.problems[file_name.to_s].last[:line].should be 2 }
    specify { critic.problems[file_name.to_s].last[:column].should be 1 }
    specify { critic.problems[file_name.to_s].last[:level].should be :error }
  end

  context "1 hard tab with 2 spaces after it" do
    let(:file_name) { :hard_tab_with_spaces }
    specify { critic.problems[file_name.to_s].size.should be 2 }
    specify { critic.problems[file_name.to_s].first[:type].should == "allow_hard_tabs"  }
    specify { critic.problems[file_name.to_s].first[:line].should be 3 }
    specify { critic.problems[file_name.to_s].first[:column].should be 0 }
    specify { critic.problems[file_name.to_s].first[:level].should be :error }
    specify { critic.problems[file_name.to_s].last[:type].should == "indentation_spaces"  }
    specify { critic.problems[file_name.to_s].last[:line].should be 3 }
    specify { critic.problems[file_name.to_s].last[:column].should be 3 }
    specify { critic.problems[file_name.to_s].last[:level].should be :error }
  end

  context "1 hard tab with 3 spaces after it" do
    let(:file_name) { :hard_tab_with_1_indented_space }
    specify { critic.problems[file_name.to_s].size.should be 1 }
    specify { critic.problems[file_name.to_s].first[:type].should == "allow_hard_tabs"  }
    specify { critic.problems[file_name.to_s].first[:line].should be 3 }
    specify { critic.problems[file_name.to_s].first[:column].should be 0 }
    specify { critic.problems[file_name.to_s].first[:level].should be :error }
  end

  context "1 hard tab with 4 spaces after it" do
    let(:file_name) { :hard_tab_with_2_indented_spaces }
    specify { critic.problems[file_name.to_s].size.should be 2 }
    specify { critic.problems[file_name.to_s].first[:type].should == "allow_hard_tabs"  }
    specify { critic.problems[file_name.to_s].first[:line].should be 3 }
    specify { critic.problems[file_name.to_s].first[:column].should be 0 }
    specify { critic.problems[file_name.to_s].first[:level].should be :error }
    specify { critic.problems[file_name.to_s].last[:type].should == "indentation_spaces"  }
    specify { critic.problems[file_name.to_s].last[:line].should be 3 }
    specify { critic.problems[file_name.to_s].last[:column].should be 5 }
    specify { critic.problems[file_name.to_s].last[:level].should be :error }
  end
end
