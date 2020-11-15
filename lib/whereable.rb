# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

require 'whereable/version'
require 'active_record'
require 'whereable_clause'

# Whereable module
module Whereable
  extend ActiveSupport::Concern

  class FilterInvalid < StandardError; end

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

  module ClassMethods
    # Parse filter to hash tree using Treetop PEG
    def whereable_hash_tree(filter)
      parser = WhereableClauseParser.new
      hash = parser.parse(filter)&.to_h

      raise FilterInvalid, "Invalid filter at #{filter[parser.max_terminal_failure_index..-1]}" if hash.nil?

      hash
    end

    # Test column validity
    def whereable_valid_column(column)
      raise FilterInvalid, "Invalid column #{column}" unless column_names.include?(column)

      column
    end

    # Test literal validity
    def whereable_valid_literal(column, literal)
      if defined_enums.key?(column)
        raise(FilterInvalid, "Invalid value #{literal} for #{column}") unless defined_enums[column].key?(literal)

        defined_enums[column][literal]
      else
        literal
      end
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
        column = whereable_valid_column(value[:column])
        literal = whereable_valid_literal(column, value[:literal])
        arel_table[column].public_send(key, literal)
      when :between
        column = whereable_valid_column(value[:column])
        literals = value[:literals]
        raise(FilterInvalid, "Invalid operation for #{column}") if defined_enums.key?(column)

        arel_table[column].between(literals)
      when :in
        column = whereable_valid_column(value[:column])
        literals = value[:literals].map { |l| whereable_valid_literal(column, l) }

        arel_table[column].in(literals)
      else
        raise FilterInvalid, "Invalid hash #{hash}"
      end
    end
  end
end
