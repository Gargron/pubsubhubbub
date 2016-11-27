# frozen_string_literal: true
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'pubsubhubbub/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'pubsubhubbub-rails'
  s.version     = Pubsubhubbub::VERSION
  s.authors     = ['Eugen Rochko']
  s.email       = ['eugen@zeonfederated.com']
  s.homepage    = 'https://github.com/Gargron/pubsubhubbub'
  s.summary     = 'A PubSubHubbub server conforming to the v0.4 spec, mountable from a Rails app'
  s.description = s.summary
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 5.0.0', '>= 5.0.0.1'
  s.add_dependency 'addressable', '~> 2.4'
  s.add_dependency 'http', '~> 2.0'
  s.add_dependency 'nokogiri', '~> 1.4'
  s.add_dependency 'link_header', '~> 0.0'
end
