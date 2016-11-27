# frozen_string_literal: true
module Pubsubhubbub
  class Engine < ::Rails::Engine
    isolate_namespace Pubsubhubbub

    config.generators do |g|
      g.test_framework :rspec, fixture: false
    end
  end
end
