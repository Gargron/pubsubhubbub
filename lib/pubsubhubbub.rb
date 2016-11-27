# frozen_string_literal: true
require 'pubsubhubbub/engine'
require 'addressable/uri'
require 'nokogiri'
require 'http'
require 'link_header'
require 'httplog'

module Pubsubhubbub
  XMLNS = 'http://www.w3.org/2005/Atom'

  class FailedDeliveryError < StandardError
  end

  class ValidationError < StandardError
  end

  mattr_accessor :verify_topic
  mattr_accessor :render_topic
end
