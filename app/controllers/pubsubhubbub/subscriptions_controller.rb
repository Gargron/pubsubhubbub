# frozen_string_literal: true
require_dependency 'pubsubhubbub/application_controller'

module Pubsubhubbub
  class SubscriptionsController < ApplicationController
    include Pubsubhubbub::Utils

    rescue_from ValidationError do |msg|
      render plain: msg, status: :unprocessable_entity
    end

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
        raise ValidationError, "Unknown mode: #{@mode}"
      end
    end

    private

    def check_topic_hub!
      return Pubsubhubbub.verify_topic.call(@topic) if Pubsubhubbub.verify_topic.is_a?(Proc)

      uri      = Addressable::URI.parse(@topic)
      response = http_client.get(uri)

      if response['Link']
        link  = LinkHeader.parse(response['Link'].is_a?(Array) ? response['Link'].first : response['Link'])
        hub   = link.find_link(%w(rel hub))
        topic = link.find_link(%w(rel self))

        return if hub&.href&.chomp('\\') == hub_url.chomp('\\') && topic&.href&.chomp('\\') == @topic.chomp('\\')
      end

      xml = Nokogiri::XML(response.body)
      xml.encoding = 'utf-8'

      link  = xml.at_xpath('//xmlns:link[@rel="hub"]', xmlns: XMLNS)
      topic = xml.at_xpath('//xmlns:link[@rel="self"]', xmlns: XMLNS)

      raise ValidationError, "Topic advertises different hub: #{link&.attribute('href')&.value}"   if link&.attribute('href')&.value&.chomp('\\')  != hub_url.chomp('\\')
      raise ValidationError, "Topic advertises different self: #{topic&.attribute('href')&.value}" if topic&.attribute('href')&.value&.chomp('\\') != @topic.chomp('\\')
    end

    def subscribe
      raise ValidationError, 'Missing callback URL' if @callback.blank?
      raise ValidationError, 'Missing topic URL' if @topic.blank?
      check_topic_hub!

      @subscription = Subscription.where(topic: @topic, callback: @callback).first_or_initialize(topic: @topic, callback: @callback)
      @subscription.mode          = @mode
      @subscription.secret        = @secret
      @subscription.lease_seconds = @lease_seconds
      @subscription.save!

      VerifyIntentJob.perform_later(@subscription.id)

      head 202
    end

    def unsubscribe
      raise ValidationError, 'Missing callback URL' if @callback.blank?
      raise ValidationError, 'Missing topic URL' if @topic.blank?
      check_topic_hub!

      @subscription = Subscription.where(topic: @topic, callback: @callback).first

      head 202 && return if @subscription.nil?
      @subscription.destroy && head(202) && return unless @subscription.confirmed?

      @subscription.update!(mode: @mode)
      VerifyIntentJob.perform_later(@subscription.id)

      head 202
    end

    def publish
      raise ValidationError, 'Missing URL' if @url.blank?
      FetchTopicJob.perform_later(hub_url, @url)
      head 202
    end
  end
end
