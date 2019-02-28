# frozen_string_literal: true

require 'rspec'

require_relative '../lists_gists.rb'

describe ListsGists do
  before do
    @lister = ListsGists.new('chrisjomaron', true, 'https://api.github.com')
  end

  it 'should return the original input params' do
    expect(@lister.username).to eq 'chrisjomaron'
  end
end
