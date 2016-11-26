# frozen_string_literal: true
module Pubsubhubbub
  class Subscription < ApplicationRecord
    validates :topic, :callback, :mode, presence: true

    scope :active, -> { where(confirmed: true).where('expires_at > ?', Time.now.utc) }

    def lease_seconds
      (expires_at - Time.now.utc).to_i
    end

    def lease_seconds=(seconds)
      self.expires_at = Time.now.utc + [[3600 * 24, seconds.to_i].max, 3600 * 24 * 30].min.seconds
    end

    before_validation :generate_challenge

    private

    def generate_challenge
      self.challenge = SecureRandom.hex
    end
  end
end
