# frozen_string_literal: true
require 'test_helper'

module Pubsubhubbub
  class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test 'POST with hub.mode=subscribe' do
      post :index, params: { 'hub.mode' => 'subscribe', 'hub.topic' => 'http://example.com/feed', 'hub.callback' => 'http://example.com/callback' }
      assert_response(:success)
    end

    test 'POST with hub.mode=unsubscribe' do
      post :index, params: { 'hub.mode' => 'unsubscribe', 'hub.topic' => 'http://example.com/feed', 'hub.callback' => 'http://example.com/callback' }
      assert_response(:success)
    end

    test 'POST with hub.mode=publish' do
      post :index, params: { 'hub.mode' => 'publish', 'hub.url' => 'http://example.com/feed' }
      assert_response(:success)
    end
  end
end
