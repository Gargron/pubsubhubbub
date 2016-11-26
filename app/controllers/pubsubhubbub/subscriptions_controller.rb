# frozen_string_literal: true
require_dependency 'pubsubhubbub/application_controller'

module Pubsubhubbub
  class SubscriptionsController < ApplicationController
    def index
      @callback      = params['hub.callback']
      @mode          = params['hub.mode']
      @topic         = params['hub.topic']
      @lease_seconds = params['hub.lease_seconds']
      @secret        = params['hub.secret']
      @url           = params['hub.url']

      case @mode
      when 'subscribe'
        subscribe
      when 'unsubscribe'
        unsubscribe
      when 'publish'
        publish
      else
        render plain: 'Unknown mode', status: :unprocessable_entity
      end
    end

    private

    def check_topic_hub
      uri      = Addressable::URI.parse(@topic)
      response = HTTP.get(uri)

      if response['Link']
        link  = LinkHeader.parse(response['Link'].is_a?(Array) ? response['Link'].first : response['Link'])
        hub   = link.find_link(%w(rel hub))
        topic = link.find_link(%w(rel self))

        return true if hub&.href == hub_url && topic&.href == @topic
      end

      xml = Nokogiri::XML(response.body)
      xml.encoding = 'utf-8'

      link  = xml.at_xpath('//xmlns:link[@rel="hub"]')
      topic = xml.at_xpath('//xmlns:link[@rel="self"]')

      link['href'] == hub_url && topic['href'] == @topic
    end

    def subscribe
      render(plain: 'Missing callback URL', status: :unprocessable_entity) && return if @callback.blank?
      render(plain: 'Missing topic URL', status: :unprocessable_entity) && return if @topic.blank?
      render(plain: 'Topic advertises a different hub or topic URL', status: :unprocessable_entity) && return unless check_topic_hub

      @subscription = Subscription.where(topic: @topic, callback: @callback).first_or_initialize(topic: @topic, callback: @callback, mode: @mode, secret: @secret)
      @subscription.lease_seconds = @lease_seconds
      @subscription.save!

      VerifyIntentJob.perform_later(@subscription.id)

      head 202
    end

    def unsubscribe
      render(plain: 'Missing callback URL', status: :unprocessable_entity) && return if @callback.blank?
      render(plain: 'Missing topic URL', status: :unprocessable_entity) && return if @topic.blank?
      render(plain: 'Topic advertises a different hub or topic URL', status: :unprocessable_entity) && return unless check_topic_hub

      @subscription = Subscription.where(topic: @topic, callback: @callback).first

      head 202 && return if @subscription.nil?
      @subscription.destroy && head(202) && return unless @subscription.confirmed?

      @subscription.update!(mode: @mode)
      VerifyIntentJob.perform_later(@subscription.id)

      head 202
    end

    def publish
      render(plain: 'Missing URL', status: :unprocessable_entity) && return if @url.blank?
      FetchTopicJob.perform_later(hub_url, @url)
      head 202
    end
  end
end
