# frozen_string_literal: true
module Pubsubhubbub
  class VerifyIntentJob < ApplicationJob
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
      response = HTTP.timeout(:per_operation, write: 60, connect: 20, read: 60).get(uri, params: { 'hub.mode' => subscription.mode, 'hub.topic' => subscription.topic, 'hub.challenge' => subscription.challenge, 'hub.lease_seconds' => subscription.lease_seconds })
      response.code > 199 && response.code < 300 && response.body.to_s == subscription.challenge
    end
  end
end
