# Gyroscope


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gyroscope'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gyroscope

## Usage

```ruby
module Search
  class User < Gyroscope::SearchBase
    attribute :ids, Gyroscope::IntegerList
    attribute :name, String
    
    def build_search_scope
      scope = super
      
      if ids.present?
        scope = scope.where(id: ids)
      end
      
      if name.present?
        scope = scope.where(name: name)
      end
      
      scope
    end
  end
end

searcher = Search::User.new(name: "Bob Dole")

searcher.search # => user records!
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/avvo/gyroscope.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

