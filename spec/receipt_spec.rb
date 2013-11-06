require 'spec_helper'

describe "Receipt", :vcr, class: Pin::Receipt do
  before(:each) do
    Pin::Base.new(ENV["PIN_SECRET"], :test)
    @charge = Pin::Charges.find("ch_0kdOMXP7gG0_W_Vh8qAWdA")
    @company_details = ["ABC Widgets", "123 Fake Street Melbourne","VIC 3000", "ABN: 12 345 678 910"]
    @receipt = Pin::Receipt.new(@charge, @company_details)
  end

  it "should generate an HTML receipt  given a charge" do
    @receipt.render().should include(@charge["token"])
  end

  it "should save an index.html file for the receipt" do
    @receipt.save()
    File.read('tmp/receipt.html').should include(@charge["token"])
  end

  it "should format a number as a currency" do
    expect @receipt.send(:number_to_currency, 1989, 'null').should match(/[$,£,€]\d{1,}[.]\d{2}/)
  end

end