# frozen_string_literal: true

module Pubsubhubbub
  class DeliverPayloadJob < ApplicationJob
    queue_as :push

    def perform(hub_url, subscription_id, current_payload)
      subscription = Subscription.find(subscription_id)
      link         = LinkHeader.new([[hub_url, [%w(rel hub)]], [subscription.topic, [%w(rel self)]]])
      headers      = {}

      headers['Link']            = link
      headers['X-Hub-Signature'] = sign_payload(subscription.secret, current_payload) if subscription.secret

      response = HTTP.timeout(:per_operation, write: 60, connect: 20, read: 60)
                     .headers(headers)
                     .post(subscription.callback, body: current_payload)

      raise FailedDeliveryError unless response.code > 199 && response.code < 300
    end

    private

    def sign_payload(secret, payload)
      OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), secret, payload)
    end
  end
end
