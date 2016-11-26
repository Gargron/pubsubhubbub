# frozen_string_literal: true
module Pubsubhubbub
  class FetchTopicJob < ApplicationJob
    queue_as :push

    def perform(hub_url, url)
      return unless Subscription.where(topic: url).active.any?
      current_payload = HTTP.timeout(:per_operation, write: 60, connect: 20, read: 60).get(url).body.to_s

      Subscription.where(topic: url).active.find_each do |subscription|
        DeliverPayloadJob.perform_later(hub_url, subscription.id, current_payload)
      end
    end
  end
end