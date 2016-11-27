# frozen_string_literal: true

module Pubsubhubbub
  class DeliverPayloadJob < ApplicationJob
    include Pubsubhubbub::Utils

    queue_as :push

    def perform(hub_url, subscription_id, current_payload)
      subscription = Subscription.find(subscription_id)
      link         = LinkHeader.new([[hub_url, [%w(rel hub)]], [subscription.topic, [%w(rel self)]]])
      headers      = {}

      headers['Link']            = link.to_s
      headers['X-Hub-Signature'] = sign_payload(subscription.secret, current_payload) if subscription.secret

      response = http_client.headers(headers).post(subscription.callback, body: current_payload)

      raise FailedDeliveryError unless response.code > 199 && response.code < 300
    end

    private

    def sign_payload(secret, payload)
      hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret, payload)
      "sha1=#{hmac}"
    end
  end
end
