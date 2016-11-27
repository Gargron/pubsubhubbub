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
    before_validation :set_min_expiration

    private

    def generate_challenge
      self.challenge = SecureRandom.hex
    end

    def set_min_expiration
      self.lease_seconds = 0 unless expires_at
    end
  end
end
