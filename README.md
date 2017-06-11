Decodes the `User-Agent` header in your Rack request hash to be UTF-8. Mostly useful for headers like

    User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; Telecomunicaciones espa��olas`

which get inserted by (rather clueless) telcos, especially in packaged Android distributions (one of the many reasons why letting telcos
customize the handset is a bad idea). This library will do it's best to reencode the header in good UTF-8, and barring that will do a lossy
replacement with question-mark substitions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sanitize_user_agent_header'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sanitize_user_agent_header

In Rails the gem will be inserted into your application stack automatically. In raw Rack, install the middleware in `config.ru` like so:

    use SanitizeUserAgentHeader

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sanitize_user_agent_header.

