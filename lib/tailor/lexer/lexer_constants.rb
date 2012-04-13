require 'set'

class Tailor

  # These are important tokens that key certain styling events.  They are taken
  # from:
  # https://github.com/ruby/ruby/blob/trunk/ext/ripper/eventids2.c
  # https://github.com/ruby/ruby/blob/trunk/parse.y
  module LexerConstants
    KEYWORDS_TO_INDENT = Set.new [
      'begin',
      'case',
      'class',
      'def',
      'do',
      'else',
      'elsif',
      'ensure',
      'for',
      'if',
      'module',
      'rescue',
      'unless',
      'until',
      'when',
      'while'
    ]

    CONTINUATION_KEYWORDS = Set.new [
      'elsif',
      'else',
      'ensure',
      'rescue',
      'when'
    ]

    KEYWORDS_AND_MODIFIERS = Set.new [
      'if',
      'unless',
      'until',
      'while'
    ]

    MODIFIERS = {
      'if' => :if_mod,
      'rescue' => :rescue_mod,
      'unless' => :unless_mod,
      'until' => :until_mod,
      'while' => :while_mod
    }

    MULTILINE_OPERATORS = Set.new [
      '+', '-', '*', '**', '/', '%',    # +, -, tSTAR, tPOW, /, %
      '<', '>', '<=', '>=',             # <, >, tLEQ, tGEQ
      '=', '+=', '-=', '*=', '**=', '/=', '%=',
      '&&=', '||=', '<<=',              # ...tOP_ASGN...
      '>>', '<<',                       # tRSHFT, tLSHFT
      '!', '&', '?', ':', '^', '~',     # !, tAMPER, ?, :, ^, ~
      #'|',
      '&&', '||',                       # tANDOP, tOROP
      '==', '===', '<=>', '!=',         # tEQ, tEQQ, tCMP, tNEQ
      '=~', '!~',                       # tMATCH, tNMATCH
      '..', '...',                      # tDOT2, tDOT3
      '::',                             # tCOLON2 (not sure about tCOLON3)
      #'[]', '[]=',                      # tAREF, tASET (not sure about these)
      '=>',                             # tASSOC
      '->',                             # tLAMBDA
      '~>'                              # gem_version op
    ]

    LOOP_KEYWORDS = Set.new [
      'for',
      'until',
      'while'
    ]
  end
end
