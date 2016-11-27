# frozen_string_literal: true
Rails.application.routes.draw do
  mount Pubsubhubbub::Engine => '/pubsubhubbub'
end
