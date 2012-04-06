require 'ripper'
require_relative '../../../spec_helper'
require 'tailor/rulers/indentation_spaces_ruler/indentation_helpers'


describe Tailor::Rulers::IndentationSpacesRuler::IndentationHelpers do
  let!(:config) { 5 }

  before do
    subject.instance_variable_set(:@config, config)
  end

  subject do
    Class.new do
      include Tailor::Rulers::IndentationSpacesRuler::IndentationHelpers
    end.new
  end

  describe "#should_be_at" do
    it "returns @proper[:this_line]" do
      subject.instance_variable_set(:@proper, { this_line: 321 })
      subject.should_be_at.should == 321
    end
  end

  describe "#next_should_be_at" do
    it "returns @proper[:next_line]" do
      subject.instance_variable_set(:@proper, { next_line: 123 })
      subject.next_should_be_at.should == 123
    end
  end

  describe "#decrease_this_line" do
    let!(:config) { 27 }

    context "#started? is true" do
      before { subject.stub(:started?).and_return true }

      context "@proper[:this_line] gets decremented < 0" do
        it "sets @proper[:this_line] to 0" do
          subject.instance_variable_set(:@proper, {
            this_line: 0, next_line: 0
          })

          subject.decrease_this_line
          proper_indentation = subject.instance_variable_get(:@proper)
          proper_indentation[:this_line].should == 0
        end
      end

      context "@proper[:this_line] NOT decremented < 0" do
        it "decrements @proper[:this_line] by @config" do
          subject.instance_variable_set(:@proper, {
            this_line: 28, next_line: 28
          })
          subject.decrease_this_line

          proper_indentation = subject.instance_variable_get(:@proper)
          proper_indentation[:this_line].should == 1
        end
      end
    end

    context "#started? is false" do
      before { subject.stub(:started?).and_return false }

      it "does not decrement @proper[:this_line]" do
        subject.instance_variable_set(:@proper, {
          this_line: 28, next_line: 28
        })
        subject.decrease_this_line

        proper_indentation = subject.instance_variable_get(:@proper)
        proper_indentation[:this_line].should == 28
      end
    end
  end

  describe "#increase_next_line" do
    context "#started? is true" do
      before { subject.stub(:started?).and_return true }

      it "increases @proper[:next_line] by @config" do
        expect { subject.increase_next_line }.to change{subject.next_should_be_at}.
          by(config)
      end
    end

    context "#started? is false" do
      before { subject.stub(:started?).and_return false }

      it "does not increases @proper[:next_line]" do
        expect { subject.increase_next_line }.to_not change{subject.next_should_be_at}.
          by(config)
      end
    end
  end

  describe "#decrease_next_line" do
    let!(:config) { 27 }

    context "#started? is true" do
      before { subject.stub(:started?).and_return true }

      it "decrements @proper[:next_line] by @config" do
        expect { subject.decrease_next_line }.to change{subject.next_should_be_at}.
          by(-config)
      end
    end

    context "#started? is false" do
      before { subject.stub(:started?).and_return false }

      it "decrements @proper[:next_line] by @config" do
        expect { subject.decrease_next_line }.to_not change{subject.next_should_be_at}.
          by(-config)
      end
    end
  end

  describe "#set_up_line_transition" do
    pending
  end

  describe "#transition_lines" do
    context "#started? is true" do
      before { subject.stub(:started?).and_return true }

      it "sets @proper[:this_line] to @proper[:next_line]" do
        subject.instance_variable_set(:@proper, { next_line: 33 })

        expect { subject.transition_lines }.to change{subject.should_be_at}.
          from(subject.should_be_at).to(subject.next_should_be_at)
      end
    end

    context "#started? is true" do
      before { subject.stub(:started?).and_return false }

      it "sets @proper[:this_line] to @proper[:next_line]" do
        subject.instance_variable_set(:@proper, { next_line: 33 })

        expect { subject.transition_lines }.to_not change{subject.should_be_at}.
          from(subject.should_be_at).to(subject.next_should_be_at)
      end
    end
  end

  describe "#start" do
    it "sets @do_measurement to true" do
      subject.instance_variable_set(:@do_measurement, false)
      subject.start
      subject.instance_variable_get(:@do_measurement).should be_true
    end
  end

  describe "#stop" do
    it "sets @do_measurement to false" do
      subject.instance_variable_set(:@do_measurement, true)
      subject.stop
      subject.instance_variable_get(:@do_measurement).should be_false
    end
  end

  describe "#started?" do
    context "@do_measurement is true" do
      before { subject.instance_variable_set(:@do_measurement, true) }
      specify { subject.started?.should be_true }
    end

    context "@do_measurement is false" do
      before { subject.instance_variable_set(:@do_measurement, false) }
      specify { subject.started?.should be_false }
    end
  end

  describe "#update_actual_indentation" do
    let(:lexed_line) do
      double "LexedLine"
    end

    context "lexed_line_output.end_of_multi_line_string? is true" do
      before do
        lexed_line.stub(:end_of_multi_line_string?).and_return true
      end

      it "returns without updating @actual_indentation" do
        lexed_line.should_not_receive(:first_non_space_element)
        subject.update_actual_indentation(lexed_line)
      end
    end

    context "lexed_line_output.end_of_multi_line_string? is false" do
      before do
        lexed_line.stub(:end_of_multi_line_string?).and_return false
        lexed_line.stub(:first_non_space_element).
          and_return first_non_space_element
      end

      context "when indented" do
        let(:first_non_space_element) do
          [[1, 5], :on_comma, ',']
        end

        it "returns the column value of that element" do
          subject.update_actual_indentation(lexed_line)
          subject.instance_variable_get(:@actual_indentation).should == 5
        end
      end

      context "when not indented" do
        let(:first_non_space_element) do
          [[1, 0], :on_kw, 'class']
        end

        it "returns the column value of that element" do
          subject.update_actual_indentation(lexed_line)
          subject.instance_variable_get(:@actual_indentation).should == 0
        end
      end
    end
  end

  describe "#valid_line?" do
    pending
  end

  describe "#single_line_indent_statement?" do
    pending
  end

  describe "#multi_line_braces?" do
    pending
  end

  describe "#multi_line_brackets?" do
    pending
  end

  describe "#multi_line_parens?" do
    pending
  end

  describe "#in_tstring?" do
    pending
  end

  describe "#r_event_with_content?" do
    context ":on_rparen" do
      context "line is '  )'" do
        let(:current_line) do
          l = double "LexedLine"
          l.stub(:first_non_space_element).and_return [[1, 2], :on_rparen, ")"]

          l
        end

        it "returns true" do
          subject.r_event_without_content?(current_line, 1, 2).should be_true
        end
      end

      context "line is '  })'" do
        let(:current_line) do
          l = double "LexedLine"
          l.stub(:first_non_space_element).and_return [[1, 2], :on_rbrace, "}"]

          l
        end

        it "returns false" do
          subject.r_event_without_content?(current_line, 1, 3).should be_false
        end
      end

      context "line is '  def some_method'" do
        let(:current_line) do
          l = double "LexedLine"
          l.stub(:first_non_space_element).and_return [[1, 0], :on_kw, "def"]

          l
        end

        it "returns false" do
          subject.r_event_without_content?(current_line, 1, 3).should be_false
        end
      end
    end
  end
end
