require_relative '../spec_helper'
require 'tailor/line_lexer'

describe Tailor::LineLexer do
  describe "#on_kw" do
    it "sets indentation level to 1 when a method is defined" do
      lexer = Tailor::LineLexer.new("def a_method\nend")
      expect { lexer.parse }.to change { lexer.indentation_tracker }.from([]).to(
        [{ type: :method, inner_level: 1 }]
      )
    end

    it "sets indentation level to 1 when a class is defined" do
      lexer = Tailor::LineLexer.new("class Thing\nend")
      expect { lexer.parse }.to change { lexer.indentation_tracker }.from([]).to(
        [{ type: :class, inner_level: 1 }]
      )
    end

    it "sets indentation level to 1 then back to 0 when a class is defined" do
      lexer = Tailor::LineLexer.new("class Thing\nend")
      expect { lexer.parse }.not_to change {
        lexer.instance_variable_get(:@proper_indentation_level)
      }
    end
  end

  describe "#on_nl" do
    it "finds bad indentation" do
      source = "class Thing\nnot_indented = 0\nend"
      lexer = Tailor::LineLexer.new source
      expect { lexer.parse }.to raise_error "hell"
    end

    it "skips good indentation" do
      source = "class Thing\n  not_indented = 0\nend"
      lexer = Tailor::LineLexer.new source
      expect { lexer.parse }.to raise_error "hell"
    end
  end
end
