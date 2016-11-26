# frozen_string_literal: true
Pubsubhubbub::Engine.routes.draw do
  post '/', to: 'subscriptions#index', as: :hub
end
