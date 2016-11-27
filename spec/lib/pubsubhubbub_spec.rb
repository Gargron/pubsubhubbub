# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Pubsubhubbub do
  it 'is a module' do
    expect(Pubsubhubbub).to be_a Module
  end

  describe 'verify_token configuration' do
    before do
      Pubsubhubbub.verify_topic = lambda { |topic_url| topic_url == 'foo' }
    end

    it 'saves a lambda' do
      expect(Pubsubhubbub.verify_topic).to be_a Proc
      expect(Pubsubhubbub.verify_topic.call('foo')).to be true
      expect(Pubsubhubbub.verify_topic.call('bar')).to be false
    end
  end
end
