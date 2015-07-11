require 'spec_helper'

RSpec.describe 'Card', :vcr, class: Pin::Card do
  before(:each) do
    Pin::Base.new(ENV['PIN_SECRET'], :test)
  end

  it 'should create a card and respond with the card detail from pin' do
    options = { number: '5520000000000000', expiry_month: '12', expiry_year: '2018', cvc: '123', name: 'Roland Robot', address_line1: '123 Fake Road', address_line2: '', address_city: 'Melbourne', address_postcode: '1223', address_state: 'Vic', address_country: 'AU' }
    expect(Pin::Card.create(options)['token']).to match(/^[a-z]{4}[_]/)
  end
end
