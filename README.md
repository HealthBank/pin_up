## pin_up

A Ruby gem wrapper for the pin-payments (pinpayments.com) API, all of it.

Support for Ruby Ruby 2.x.x

[![Build Status](https://travis-ci.org/dNitza/pin_up.png)](https://travis-ci.org/dNitza/pin_up)
[![Code Climate](https://codeclimate.com/github/dNitza/pin_up.png)](https://codeclimate.com/github/dNitza/pin_up)

## Installation

    gem install pin_up

or add:

    gem 'pin_up'

to your Gemfile.

## Usage

If using rails add an initializer to your app:

    Pin::Base.new("your key", :env, timeout)

An optional second parameter can be passed in to set the environment (:live or :test). The default is :live.

An optional third parameter can be passed in to set the timeout of HTTParty in seconds. The default is `1800` (30 minutes).

## Charges
##### List All Charges
    Pin::Charges.all

Show charges on a particular page:

    Pin::Charges.all(6)

With Pagination:

    Pin::Charges.all(6,true)
    # request = Pin::Charges.all(6,true)
    # request[:response] => response hash
    # request[:pagination] => "pagination":{"current":6,"previous":5,"next":7,"per_page":25,"pages":1,"count":15}

##### Find A Charge
    Pin::Charges.find("token")
##### Search For Charges
    Pin::Charges.search(query: "foo", end_date: "Mar 25, 2013")

Show found charges on a particular page:

    Pin::Charges.search(3, query: "foo", end_date: "Mar 25, 2013")

With Pagination:

    Pin::Charges.search(3, true, query: "foo", end_date: "Mar 25, 2013")
    # request = Pin::Charges.search(3, true, query: "foo", end_date: "Mar 25, 2013")
    # request[:response] => response hash
    # request[:pagination] => "pagination":{"current":3,"previous":2,"next":4,"per_page":25,"pages":10,"count":239}

See [Pin Payments Charges API](https://pinpayments.com/developers/api-reference/charges#search-charges) for a full list of options.

##### Create A Charge
    charge = {email: "email@example.com", description: "Description", amount: "400", currency: "AUD", ip_address: "127.0.0.1", customer_token: "cus_token"   }

    Pin::Charges.create(charge)

##### Authorise A Charge (but don't charge it yet)
Also known as a pre-auth, this will hold a charge to be captured by for up to 5 days

    charge = {email: "email@example.com", description: "Description", amount: "400", currency: "AUD", ip_address: "127.0.0.1", customer_token: "cus_token"  capture: false }

    Pin::Charges.create(charge)

##### Capture an authorised charge
    Pin::Charges.capture(charge)

## Customers
##### List All Customers
    Pin::Customer.all

Show customers on a particular page:

    Pin::Customer.all(3)

With Pagination:

    Pin::Customer.all(3,true)

##### Find A Customer
    Pin::Customer.find('token')
##### List Charges For A Customer
    Pin::Customer.charges('cus_token')

Show customers on a particular page:

    Pin::Customer.charges(6)

With Pagination:

    Pin::Customer.all(6,true)
    # request = Pin::Customer.all(6,true)
    # request[:response] => response hash
    # request[:pagination] => "pagination":{"current":6,"previous":5,"next":7,"per_page":25,"pages":1,"count":15}

##### Create A Customer
    Pin::Customer.create(email, hash_of_customer_details)

    customer_details = {number: '5520000000000000', expiry_month: "12", expiry_year: "2014", cvc: "123", name: 'Roland Robot', address_line1: '123 fake street', address_city: 'Melbourne', address_postcode: '1234', address_state: 'Vic', address_country: 'Australia'}

    Pin::Customer.create('email@example.com', customer_details)

##### Update A Customer
###### Update Card details

    Pin::Customer.update('cus_token', hash_of_details)

If passing a hash of details, it must be the full list of details of the credit card to be stored. (https://pinpayments.com/docs/api/customers#put-customer)

###### Update only an email

    hash_of_details = {email: 'new_email@example.com'}
    Pin::Customer.update('cus_token', hash_of_details)

###### Update card by token

    hash_of_details = {card_token: 'new_card_token'}
    Pin::Customer.update('cus_token', hash_of_details)

##### Create A Customer Given a Card Token and Email

    card_details = {number: "5520000000000000", expiry_month: "12", expiry_year: "2018", cvc: "123", name: "Roland TestRobot", address_line1: "123 Fake Road", address_line2: "", address_city: "Melbourne", address_postcode: "1223", address_state: "Vic", address_country: "AU"}

    card = Pin::Card.create(card_details)
    Pin::Customer.create('email@example.com',card['token'])

##### List cards for a customer

    token = 'customer_token'
    Pin::Customer.cards(token)

##### Create a card for a customer (this does not replace their primary card)

    customer_token = 'customer_token'
    card = { number: '5520000000000000', expiry_month: '12', expiry_year: '2018', cvc: '123', name: 'Roland TestRobot', address_line1: '123 Fake Road', address_line2: '', address_city: 'Melbourne', address_postcode: '1223', address_state: 'Vic', address_country: 'AU' }
    Pin::Customer.create_card(customer_token, card)

You can also use a card token rather than a card hash

    customer_token = 'customer_token'
    card_token = 'card_token'
    Pin::Customer.create_card(customer_token, card_token)

##### Delete a card given a customer and a token
This method will raise an exception if attempting to remove the user's primary card

    customer_token = 'customer_token'
    card_token = 'card_token'
    Pin::Customer.delete_card(customer_token, card_token)

##### Delete a customer and all of its cards

    customer_token = 'customer_token'
    Pin::Customer.delete(customer_token)

## Refunds

##### Find A Refund

    Pin::Refund.find('charge_token')

This will list all refunds for a particular charge (will return an empty hash if nothing is found)

##### Get A Refund

    Pin::Refund.get('refund_token')

This will return the details of the specified refund ( will throw a `Pin::ResourceNotFound` if nothing is found)

##### Create A Refund Specifying An Amount

    Pin::Refund.create('charge_token', '400')

##### Create A Refund For Entire Charge Amount

    Pin::Refund.create('charge_token')

## Cards

##### Create A Card Without Pins Form

    card_details = {number: "5520000000000000", expiry_month: "12", expiry_year: "2018", cvc: "123", name: "Roland Robot", address_line1: "123 Fake Road", address_line2: "", address_city: "Melbourne", address_postcode: "1223", address_state: "Vic", address_country: "AU"}

    Pin::Card.create(card_details)

Will return a card_token that can be stored against a customer.

Only use this method if you're comfortable sending card details to your server - otherwise you can use a form that Pin provides (https://pinpayments.com/developers/integration-guides/payment-forms) and get the card_token that way.

## Plans
##### Create A Plan
    Pin::Plan.create(plan)

    plan = { name: 'Coffee Plan',
             amount: '1000',
             currency: 'AUD',
             interval: 30,
             interval_unit: 'day',
             setup_amount: 0,
             trial_amount: 0,
             trial_interval: 7,
             trial_interval_unit: 'day' }

Note: setup_amount, trial_amount, trial_interval and trial_interval_unit are all optional fields.

    Pin::Plan.create(plan)

##### List All Plans
    Pin::Plan.all

Show Plans on a particular page:

    Pin::Plan.all(3)

With Pagination:

    Pin::Plan.all(3,true)

##### Find a Plan

    Pin::Plan.find(plan_token)

    Return the details of a specified plan

##### Update a Plan
Update the name of a specified plan. Only the plan name can be updated!

    Pin::Plan.update(plan_token, name_hash)

    name_hash = { name: 'new_plan_name' }

##### Delete a Plan
Deletes a plan and all of its subscriptions. You will not be able to recover this.

Note: Plans can only be deleted if they have no running subscriptions.

    Pin::Plan.delete(plan_token)

## Subscriptions
##### Create A Subscription
Activate a new subscription and return its details. The customer's card will immeadiately be billed the initial plan amount, unless there's a trial period.


    subscription =     { plan_token: plan_token,
                         customer_token: customer_token,
                         card_token: card_token,
                         include_setup_fee: true }

Note: card_token and include_setup_fee are both optional.

    Pin::Subscription.create(subscription)

##### List All Subscriptions

    Pin::Subscription.all

Show Subscriptions on a particular page:

    Pin::Subscription.all(3)

With Pagination:

    Pin::Subscription.all(3,true)

##### Find a Subscription
Return the details of a subscription.

    Pin::Subscription.find(subscription_token)

##### Update a Subscription
Updates the card associated with a subscription identified by the subscription token.

Note: The card token must already be associated to the customer of the subscription.

    Pin::Subscription.update(subscription_token, card_token)

##### Delete a Subscription
Cancels the subscription identified by the subscription token. Subscriptions can only be cancelled if they are in a trial or active state.

Note: Subscriptions will only attain a cancelled state once the subscription period has elapsed. Until such time subscriptions will be in a state of 'Cancelling'.

    Pin::Subscription.delete(plan_token)

##### Reactivate a Subscription
Reactivates the subscription identified by the subscription token returning the details of the subscription

    Pin::Subscription.reactivate(plan_token)

##### List Subscription history
Fetch the ledger entries relating to a subscription identified by a subscription token

    Pin::Subscription.history(subscription_token)

###### With pagination

    Pin::Subscription.history(subscription_token, 3, true)

## Recipients
The recipients API allows you to post bank account details and retrieve a token that you can safely store in your app. You can send funds to recipients using the [transfers API].

##### Create a new recipient and returns its details
`options = { email: 'hello@example.com', name: 'Roland Robot', bank_account: { name: 'Roland Robot', bsb: '123456', number: 987654321 } } `

`Pin::Recipient.create(options)`

##### Get a paginated list of all recipients.
`Pin::Recipient.all `

##### Get the details of a recipient.
`Pin::Recipient.find(recipient_token) `

##### Update the given details of a recipient and return its details.
`Pin::Recipient.update(recipient_token, updated_options_hash)`

##### Get a paginated list of a recipient's transfers.
`Pin::Recipient.transfers(recipient_token) `

## Transfers
The transfers API allows you to send money to Australian bank accounts, and to retrieve details of previous transfers.

##### Create a new transfer and returns its details.
`transfer = { amount: 400, currency: 'AUD', description: 'Pay day', recipient: recipient_token } `

`Pin::Transfer.create(transfer) `

##### Get a paginated list of all transfers.
`Pin::Transfer.all `

##### Get the details of a transfer.
`Pin::Transfer.find(transfer_token)`

##### Search for transfers
    Pin::Transfer.search(query: "foo", end_date: "Mar 25, 2013")

Show found transfers on a particular page:

    Pin::Transfer.search(3, query: "foo", end_date: "Mar 25, 2013")

With Pagination:

    Pin::Transfer.search(3, true, query: "foo", end_date: "Mar 25, 2013")
    # request = Pin::Transfer.search(3, true, query: "foo", end_date: "Mar 25, 2013")
    # request[:response] => response hash
    # request[:pagination] => "pagination":{"current":3,"previous":2,"next":4,"per_page":25,"pages":10,"count":239}

See [Pin Payments Transfers API](https://pinpayments.com/developers/api-reference/transfers#search-transfers) for a full list of options.

##### Get the line items associated with transfer.
`Pin::Transfer.line_items(transfer_token)`

## Balance
The balance API allows you to see the current balance of funds in your Pin Payments account. You can use this to confirm whether a [transfer] is possible.

Returns the current balance of your Pin Payments account. Transfers can only be made using the funds in the `available` balance. The `pending` amount will become available after the 7 day settlement schedule on your charges.

`Pin::Balance.get `

## Bank Accounts
The bank account API allows you to securely store bank account details in exchange for a bank account token. This token can then be used to create a recipient using the [recipients API].
A bank account token can only be used once to create a recipient. The token automatically expires after 1 month if it hasn’t been used.

##### Create a bank account and return its details.
`options = { name: 'Roland Robot', bsb: '123456', number: '987654321' } `

`Pin::BankAccounts.create(options) `

## Webhook Endpoints
The Webhook Endpoints API allows you to create and view your webhook endpoints to enable your website to receive push notifications of events that occur on your Pin Payments account.

##### Create a new webhook endpoint and returns its details.
`options = { url: "http://example.com/webhooks/" }`

`Pin::WebhookEndpoints.create(options)`

##### Get a paginated list of all webhook endpoints.
`Pin::WebhookEndpoints.all`

##### Get the details of a webhook endpoint.
`Pin::WebhookEndpoints.find(token)`

##### Delete a webhook endpoint and all of its webhook requests. You will not be able to recover them.
`token = "whe_foobar"`
`Pin::WebhookEndpoints.delete(token)`

## Receipts

Receipts have been extracted out into their [own gem](https://github.com/dNitza/pin_up_receipts)

## Exceptions

A number of different error types are built in:

### ResourceNotFound
The requested resource could not be found in Pin.

### InvalidResource
A number of parameters sent to Pin were invalid.

### ChargeError
Something went wrong while creating a charge in Pin. This could be due to insufficient funds, a card being declined or expired. A full list of possible errors is available [here](https://pinpayments.com/developers/api-reference/charges).

### InsufficientPinBalance

N.B. All of the above errors return an error object with a `message` and a `response` attribute. The response is the raw response from Pin (useful for logging).

### ClientError
An unsupported HTTP verb was used.

### Unauthorized
Authorization credentials are wrong. Most likely the authorization token needs to be checked.

## Testing locally
Create a YAML file under 'spec' called 'test_data.yml' and add in:

    PIN_SECRET: "your pin test secret"

uncomment line 16 in spec_helper.rb and

run

    rspec spec/*.rb

### Record New VCR cassettes
After cloning the project one should create a new set of cassettes.

In spec_helper change

    VCR.use_cassette(name, options) { example.call }
to

    VCR.use_cassette(name, record: :all) { example.call }

Run all tests and then change the line back (replace record: :all with options)

### Updating VCR test cassettes
A contributor can update cassettes previously recorded by adding the following syntax:

     record: :all, :match_requests_on => [:method, :host, :path]

E.g. in a particular spec file:

    describe Pin::Balance, :vcr, record: :all, :match_requests_on => [:method, :host, :path] do

## Contributing to pin_up

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) Daniel Nitsikopoulos. See LICENSE.txt for
further details.
