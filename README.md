# Pubsubhubbub

[![Gem Version](http://img.shields.io/gem/v/pubsubhubbub-rails.svg)][gem]
[![Dependency Status](http://img.shields.io/gemnasium/Gargron/pubsubhubbub.svg)][gemnasium]

[gem]: https://rubygems.org/gems/pubsubhubbub-rails
[gemnasium]: https://gemnasium.com/Gargron/pubsubhubbub

This is a mountable PubSubHubbub server conforming to the v0.4 of the spec.

## Usage

In `routes.rb`:

    mount Pubsubhubbub::Engine => '/pubsubhubbub', as: :pubsubhubbub

In feed:

    <link rel="hub" href="<%= pubsubhubbub_hub_url %>" />

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'pubsubhubbub-rails'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install pubsubhubbub-rails
```

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
