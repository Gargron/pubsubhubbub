# frozen_string_literal: true
module Pubsubhubbub
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
