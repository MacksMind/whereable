[![Gem Version](https://badge.fury.io/rb/whereable.svg)](https://badge.fury.io/rb/whereable)

# Whereable

Translates where-like filter syntax into an Arel-based ActiveRecord scope, so you can safely use SQL syntax in Rails controller parameters.
What it lacks in power, it gains in simplicity and ease of use for API consumers.

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'whereable'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install whereable

## Usage

Imagine a User model:
``` ruby
class User < ActiveRecord::Base
  include Whereable

  validates :username, presence: true, uniqueness: true

  validates :born_on, presence: true

  enum role: { standard: 0, admin: 1 }
end
```
With this data:
``` ruby
User.create!(username: 'Morpheus', role: :admin, born_on: '1961-07-30')
User.create!(username: 'Neo', role: :standard, born_on: '1964-09-02')
User.create!(username: 'Trinity', role: :standard, born_on: '1967-08-21')
```
Let's assume you're allowing filtered API access to your Users,
but using the `#standard` scope to keep admins hidden. So your controller might include:
``` ruby
User.standard.where(params[:filter])
```
And your white hat API consumers pass in `filter=born_on < '1967-01-01'`, and &hellip;
``` ruby
User.standard.where("born_on < '1967-01-01'")
```
returns Neo as expected, so we're all good.

*Meanwhile&hellip;* Your black hat API consumer passes in `filter=true) or (true`, and &hellip;
``` ruby
User.standard.where("true) or (true")
```
returns **EVERYONE**, because the database query is &hellip;
``` SQL
SELECT "users".* FROM "users" WHERE "users"."role" = 0 AND (true) or (true)
```
*This is how the Matrix gets hacked.*

Instead add `include Whereable` to your model, and change your controller to:
``` ruby
User.standard.whereable(params[:filter])
```
And then &hellip;
``` ruby
User.standard.whereable("born_on < '1967-01-01'")
```
returns Neo as before, but &hellip;
``` ruby
User.standard.whereable("true) or (true")
```
raises exception &hellip;
``` ruby
Whereable::FilterInvalid ('Invalid filter at ) or (true')
```

### Syntax
* Supports and/or with nested parentheses as needed
* Recognizes these operators: `eq ne gte gt lte lt = != <> >= > <= <`, plus `IN` and `BETWEEN`
* Column must be to left of operator, and literal(s) to right
  * Comparing columns to each other is *not* supported
  * `BETWEEN` requires two literals separated by `AND`
    * Example: `publish_at between '2020-11-01 12:00 EST' and '2020-11-15 23:59:59 EST'`
  * `IN` requires comma-separated literals in parentheses
    * Example: `username in (Morpheus, Trinity)`
* Quotes are optional unless the literal contains spaces or quotes
  * Supports double or single quotes, and embedded quotes may be backslash escaped
  * Also supports the PostgreSQL double-single embedded quote
* Enum literals must use the *name*, not the database value:
  * 👍 `User.whereable('role = admin')`
  * 👎 `User.whereable('role = 1')`

### More
See the [Wiki](https://github.com/MacksMind/whereable/wiki) for more.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MacksMind/whereable.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
