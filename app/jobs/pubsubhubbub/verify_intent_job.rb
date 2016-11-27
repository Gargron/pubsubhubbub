# frozen_string_literal: true
module Pubsubhubbub
  class VerifyIntentJob < ApplicationJob
    include Pubsubhubbub::Utils

    queue_as :push

    def perform(subscription_id)
      subscription = Subscription.find(subscription_id)
      verified     = verify_intent(subscription)

      if verified && subscription.mode == 'subscribe'
        subscription.update(confirmed: true)
      else
        subscription.destroy
      end
    end

    private

    def verify_intent(subscription)
      uri = Addressable::URI.parse(subscription.callback)
      response = http_client.get(uri, params: { 'hub.mode' => subscription.mode, 'hub.topic' => subscription.topic, 'hub.challenge' => subscription.challenge, 'hub.lease_seconds' => subscription.lease_seconds })
      response.code > 199 && response.code < 300 && response.body.to_s == subscription.challenge
    end
  end
end
