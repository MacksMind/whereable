# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

require 'whereable/version'
require 'active_record'
require 'active_support'
require 'treetop'
require 'whereable.treetop'

# Whereable module
module Whereable
  extend ActiveSupport::Concern

  class FilterInvalid < StandardError; end

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
      OP_SYMS[text_value] || text_value.downcase.to_sym
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

  included do
    scope(
      :whereable,
      lambda do |filter|
        return all if filter.blank?

        hash_tree = whereable_hash_tree(filter)

        where(whereable_deparse(hash_tree))
      end,
    )
  end

  class_methods do
    # Parse filter to hash tree using Treetop PEG
    def whereable_hash_tree(filter)
      parser = WhereableParser.new
      hash = parser.parse(filter)&.to_h

      raise FilterInvalid, "Invalid filter at #{filter[parser.max_terminal_failure_index..-1]}" if hash.nil?

      hash
    end

    # deparse hash tree to Arel
    def whereable_deparse(hash)
      raise FilterInvalid, "Invalid hash #{hash}" if hash.size > 1

      key, value = hash.first

      case key
      when :and, :or
        arel = whereable_deparse(value.first)
        value[1..-1].each do |o|
          arel = arel.public_send(key, whereable_deparse(o))
        end
        arel
      when :eq, :not_eq, :gt, :gteq, :lt, :lteq
        column = value[:column]
        literal = value[:literal]
        raise FilterInvalid, "Invalid column #{column}" unless column_names.include?(column)

        if defined_enums.key?(column)
          literal = defined_enums[column][literal] || raise(FilterInvalid, "Invalid value #{literal} for #{column}")
        end
        arel_table[column].public_send(key, literal)
      else
        raise FilterInvalid, "Invalid hash #{hash}"
      end
    end
  end
end
