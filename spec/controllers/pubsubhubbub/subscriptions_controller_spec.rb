# frozen_string_literal: true
require 'rails_helper'

module Pubsubhubbub
  RSpec.describe SubscriptionsController, type: :controller do
    routes { Pubsubhubbub::Engine.routes }

    before do
      stub_request(:get, 'http://example.com/feed').to_return(status: 200, body: 'foo', headers: { 'Link' => '<http://test.host/pubsubhubbub/>; rel="hub", <http://example.com/feed>; rel="self"' })
    end

    describe 'POST #index' do
      context 'with subscribe request' do
        before do
          stub_request(:get, 'http://example.com/callback').with(query: hash_including('hub.mode' => 'subscribe')).to_return { |req| { body: req.uri.query_values['hub.challenge'] } }
          post :index, use_route: :pubsubhubbub, params: { 'hub.mode' => 'subscribe', 'hub.topic' => 'http://example.com/feed', 'hub.callback' => 'http://example.com/callback' }
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end

        it 'creates and confirms a subscription' do
          subscription = Subscription.where(topic: 'http://example.com/feed').first

          expect(subscription).to_not be_nil
          expect(subscription.confirmed?).to be true
        end
      end

      context 'with unsubscribe request' do
        before do
          post :index, use_route: :pubsubhubbub, params: { 'hub.mode' => 'unsubscribe', 'hub.topic' => 'http://example.com/feed', 'hub.callback' => 'http://example.com/callback' }
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'with publish request' do
        before do
          stub_request(:post, 'http://example.com/callback').with(headers: { 'Link' => '<http://test.host/pubsubhubbub/>; rel="hub", <http://example.com/feed>; rel="self"' }, body: 'foo').to_return(status: 200)
          Subscription.create!(topic: 'http://example.com/feed', callback: 'http://example.com/callback', mode: 'subscribe', confirmed: true)
          post :index, use_route: :pubsubhubbub, params: { 'hub.mode' => 'publish', 'hub.url' => 'http://example.com/feed' }
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end

        it 'performs a delivery' do
          expect(a_request(:post, 'http://example.com/callback').with(headers: { 'Link' => '<http://test.host/pubsubhubbub/>; rel="hub", <http://example.com/feed>; rel="self"' }, body: 'foo')).to have_been_made.once
        end
      end
    end
  end
end
