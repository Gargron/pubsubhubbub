# frozen_string_literal: true
require 'pubsubhubbub/engine'
require 'pubsubhubbub/version'
require 'addressable/uri'
require 'nokogiri'
require 'http'
require 'link_header'

module Pubsubhubbub
  XMLNS = 'http://www.w3.org/2005/Atom'

  class FailedDeliveryError < StandardError
  end

  class ValidationError < StandardError
  end

  mattr_accessor :verify_topic
  mattr_accessor :render_topic

  def self.publish(hub_url, topic_url)
    FetchTopicJob.perform_later(hub_url, topic_url)
  end

  module Utils
    def http_client
      HTTP.timeout(:per_operation, write: 30, connect: 20, read: 30)
          .headers(user_agent: "PubSubHubbub/#{Pubsubhubbub::VERSION}")
    end
  end
end
