# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

RSpec.describe Whereable do
  it 'has a version number' do
    expect(Whereable::VERSION).not_to be(nil)
  end

  describe '#whereable_hash_tree' do
    {
      'filters eq' => {
        filter: 'col eq 100',
        tree: {
          eq: { column: 'col', literal: '100' },
        },
      },
      'filters ne' => {
        filter: 'col ne 100',
        tree: {
          not_eq: { column: 'col', literal: '100' },
        },
      },
      'filters gte' => {
        filter: 'col gte 100',
        tree: {
          gteq: { column: 'col', literal: '100' },
        },
      },
      'filters gt' => {
        filter: 'col gt 100',
        tree: {
          gt: { column: 'col', literal: '100' },
        },
      },
      'filters lte' => {
        filter: 'col lte 100',
        tree: {
          lteq: { column: 'col', literal: '100' },
        },
      },
      'filters lt' => {
        filter: 'col lt 100',
        tree: {
          lt: { column: 'col', literal: '100' },
        },
      },
      'filters =' => {
        filter: 'col = 100',
        tree: {
          eq: { column: 'col', literal: '100' },
        },
      },
      'filters !=' => {
        filter: 'col != 100',
        tree: {
          not_eq: { column: 'col', literal: '100' },
        },
      },
      'filters <>' => {
        filter: 'col <> 100',
        tree: {
          not_eq: { column: 'col', literal: '100' },
        },
      },
      'filters >=' => {
        filter: 'col >= 100',
        tree: {
          gteq: { column: 'col', literal: '100' },
        },
      },
      'filters >' => {
        filter: 'col > 100',
        tree: {
          gt: { column: 'col', literal: '100' },
        },
      },
      'filters <=' => {
        filter: 'col <= 100',
        tree: {
          lteq: { column: 'col', literal: '100' },
        },
      },
      'filters <' => {
        filter: 'col < 100',
        tree: {
          lt: { column: 'col', literal: '100' },
        },
      },
      'handles single quotes' => {
        filter: "col = 'text'",
        tree: {
          eq: { column: 'col', literal: 'text' },
        },
      },
      'handles single quotes with double single' => {
        filter: "col = 'te''xt'",
        tree: {
          eq: { column: 'col', literal: "te'xt" },
        },
      },
      'handles single quotes with escaped single' => {
        filter: "col = 'te\\'xt'",
        tree: {
          eq: { column: 'col', literal: "te'xt" },
        },
      },
      'handles double quotes' => {
        filter: 'col = "text"',
        tree: {
          eq: { column: 'col', literal: 'text' },
        },
      },
      'handles double quotes with escaped double' => {
        filter: 'col = "te\\"xt"',
        tree: {
          eq: { column: 'col', literal: 'te"xt' },
        },
      },
      'handles hugged/nested and/or' => {
        filter: '((col1=foo)or(col2=bar))and((col3=baz)or(col4=qux))',
        tree: {
          and: [
            {
              or: [
                { eq: { column: 'col1', literal: 'foo' } },
                { eq: { column: 'col2', literal: 'bar' } },
              ],
            },
            {
              or: [
                { eq: { column: 'col3', literal: 'baz' } },
                { eq: { column: 'col4', literal: 'qux' } },
              ],
            },
          ],
        },
      },
    }.each do |filter_desc, meta|
      it filter_desc do
        expect(Example.whereable_hash_tree(meta[:filter])).to eq(meta[:tree])
      end
    end

    {
      'rejects shady sql' => {
        filter: 'integer_a = 123)UNION (SELECT username from users',
        error: 'Invalid filter at )UNION (SELECT username from users',
      },
    }.each do |error_desc, meta|
      it error_desc do
        expect { Example.whereable_hash_tree(meta[:filter]) }
          .to raise_exception(Whereable::FilterInvalid, meta[:error])
      end
    end
  end

  describe '#whereable_deparse' do
    {
      'converts date to timestamp' => {
        tree: {
          lt: { column: 'created_at', literal: '2020-11-11' },
        },
        sql: "\"examples\".\"created_at\" < '2020-11-11 00:00:00'",
      },
      'converts iso8601 to db timestamp' => {
        tree: {
          lt: { column: 'created_at', literal: '2020-11-11T18:28:57Z' },
        },
        sql: "\"examples\".\"created_at\" < '2020-11-11 18:28:57'",
      },
      'converts iso8601 to db date' => {
        tree: {
          lt: { column: 'born_on', literal: '2020-11-11T18:28:57Z' },
        },
        sql: "\"examples\".\"born_on\" < '2020-11-11'",
      },
      'converts enum to database value' => {
        tree: {
          eq: { column: 'role', literal: 'admin' },
        },
        sql: '"examples"."role" = 1',
      },
    }.each do |filter_desc, meta|
      it filter_desc do
        expect(Example.whereable_deparse(meta[:tree]).to_sql).to eq(meta[:sql])
      end
    end

    {
      'rejects invalid columns' => {
        tree: {
          eq: { column: 'garbage', literal: 7 },
        },
        error: 'Invalid column garbage',
      },
      'rejects invalid enum' => {
        tree: {
          eq: { column: 'role', literal: 'addmin' },
        },
        error: 'Invalid value addmin for role',
      },
    }.each do |error_desc, meta|
      it error_desc do
        expect { Example.whereable_deparse(meta[:tree]) }
          .to raise_exception(Whereable::FilterInvalid, meta[:error])
      end
    end
  end

  describe '#whereable' do
    {
      'handles blank' => {
        filter: nil,
        sql: 'SELECT "examples".* FROM "examples"',
      },
      'handles hugged/nested and/or' => {
        filter: '((username=foo)or(username=bar))and((role=standard)or(role=admin))',
        sql: <<~SQL.tr("\n", ' ').rstrip,
          SELECT "examples".*
          FROM "examples"
          WHERE ("examples"."username" = 'foo' OR "examples"."username" = 'bar')
          AND ("examples"."role" = 0 OR "examples"."role" = 1)
        SQL
      },
    }.each do |filter_desc, meta|
      it filter_desc do
        expect(Example.whereable(meta[:filter]).to_sql).to eq(meta[:sql])
      end
    end
  end
end
