# Pubsubhubbub

This is a mountable PubSubHubbub server conforming to the v0.4 of the spec.

## Usage

In `routes.rb`:

    mount Pubsubhubbub::Engine => '/pubsubhubbub', as: :pubsubhubbub

In feed:

    <link rel="hub" href="<%= pubsubhubbub_hub_url %>" />

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'pubsubhubbub'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install pubsubhubbub
```

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
