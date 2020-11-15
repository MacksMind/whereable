# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

require 'treetop'

module WhereableClause
  Treetop.load(File.join(__dir__, 'whereable_clause.treetop'))

  module Disjunction
    # Hash for OR
    def to_h
      return conjunction.to_h if opt.empty?

      {
        or: [conjunction.to_h] + opt.elements.map { |o| o.conjunction.to_h },
      }
    end
  end

  module Conjunction
    # Hash for AND
    def to_h
      return term.to_h if opt.empty?

      {
        and: [term.to_h] + opt.elements.map { |o| o.term.to_h },
      }
    end
  end

  module NestedExpression
    # Hash for nested expression
    delegate :to_h, to: :expression
  end

  module Condition
    # Hash for comparison
    def to_h
      {
        operator.to_sym => {
          column: column.to_s,
          literal: literal.to_s,
        },
      }
    end
  end

  module Column
    # String column name
    def to_s
      text_value
    end
  end

  # Operators such as 'eq' that match their Arel equivalent aren't needed here
  OP_SYMS = {
    'ne' => :not_eq,
    'lte' => :lteq,
    'gte' => :gteq,
    '=' => :eq,
    '!=' => :not_eq,
    '<>' => :not_eq,
    '<' => :lt,
    '<=' => :lteq,
    '>' => :gt,
    '>=' => :gteq,
  }.freeze
  private_constant :OP_SYMS

  module Operator
    # Arel comparion method
    def to_sym
      OP_SYMS[text_value.downcase] || text_value.downcase.to_sym
    end
  end

  module Literal
    # Strip enclosing quotes and tranlate embedded quote patterns
    def to_s
      text_value
        .gsub(/\A['"]|['"]\z/, '')
        .gsub("''", "'")
        .gsub("\\'", "'")
        .gsub('\"', '"')
    end
  end
end
