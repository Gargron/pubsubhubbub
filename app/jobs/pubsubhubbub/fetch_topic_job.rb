# frozen_string_literal: true
module Pubsubhubbub
  class FetchTopicJob < ApplicationJob
    include Pubsubhubbub::Utils

    queue_as :push

    def perform(hub_url, url)
      return unless Subscription.where(topic: url).active.any?

      current_payload = if Pubsubhubbub.render_topic.is_a?(Proc)
                          Pubsubhubbub.render_topic.call(url)
                        else
                          http_client.get(url).body.to_s
                        end

      Subscription.where(topic: url).active.find_each do |subscription|
        DeliverPayloadJob.perform_later(hub_url, subscription.id, current_payload)
      end
    end
  end
end
