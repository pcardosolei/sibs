require "rails_helper"

RSpec.describe SibsController, type: :controller do
  describe "Make requirement for the transaction" do
    it "has a 200 status code" do
      get :transaction
      expect(response.status).to eq(200)
      expect(response.body).to include("transactionID")
    end
  end

  

  describe 'Get the status of the transaction' do

    # example from the successful result from postman.
    # you require to have a valid id from the transaction from the transaction id.

    it "has a 200 status code" do
      get :transaction
      transactionID = JSON.parse(response.body)["transactionID"]

      get :status, params: { id: transactionID }     
      expect(response.status).to eq(200)

      # will always be pending. read notes below.
      expect(response.body).to include(transactionID)
    end
  end
end


###
# Transaction
###

##

# Jumpseller does not have the Server to server authroziation so you ahve to use the form script to add to the checkout. with a redirect. 


#
# The redirect returns the transaction id and a responsePath. With the ID you can check the status of the transaction
# The status of the transaction can be success, pending and have information like the reference for the payment. be aware of that.

# normal response from the transaction request. 

=begin
{
    "amount": {
        "value": 5,
        "currency": "EUR"
    },
    "merchant": {
        "terminalId": "56795",
        "merchantTransactionId": "teste 12345"
    },
    "transactionID": "s2T3sfBjwny4V5BhcMTP",
    "transactionSignature": "eyJ0eElkIjoiczJUM3NmQmp3bnk0VjVCaGNNVFAiLCJtYyI6NDgxNTI1LCJ0YyI6NTY3OTV9.pcRyqU/RDOrKnEM6W499EZY1JtHHQH+JEiWMvFGv5Jw=.3AFhhScNnJwezoNtVHGZxrCIn1GeQSXSPCbGXEsjZIoTcf1BIVMzigF1Q6yLNHpN",
    "formContext": "eyJQYXltZW50TWV0aG9kIjpbIkNBUkQiLCJNQldBWSIsIlJFRkVSRU5DRSJdLCJUcmFuc2FjdGlvblNpZ25hdHVyZSI6ImV5SjBlRWxrSWpvaWN6SlVNM05tUW1wM2JuazBWalZDYUdOTlZGQWlMQ0p0WXlJNk5EZ3hOVEkxTENKMFl5STZOVFkzT1RWOS5wY1J5cVUvUkRPcktuRU02VzQ5OUVaWTFKdEhIUUgrSkVpV012Rkd2NUp3PS4zQUZoaFNjTm5Kd2V6b050VkhHWnhyQ0luMUdlUVNYU1BDYkdYRXNqWklvVGNmMUJJVk16aWdGMVE2eUxOSHBOIiwiQW1vdW50Ijp7IkFtb3VudCI6NSwiQ3VycmVuY3kiOiJFVVIifSwiTWFuZGF0ZSI6e30sIkFwaVZlcnNpb24iOiJ2MiIsIk1PVE8iOmZhbHNlfQ==",
    "expiry": "2024-02-05T02:35:43.348Z",
    "tokenList": [],
    "paymentMethodList": [
        "CARD",
        "MBWAY",
        "REFERENCE"
    ],
    "execution": {
        "startTime": "2024-02-05T02:25:44.037Z",
        "endTime": "2024-02-05T02:25:44.241Z"
    },
    "returnStatus": {
        "statusCode": "000",
        "statusMsg": "Success",
        "statusDescription": "Success"
    }
}
=end

##
# for the form
###

# TransactionID on the script. 
# and the form requires all the parameters that come from the transaction request.
#
#
# spg-context => formContext from above referent to the transaction.
# className => paymentSPG => the class name for the form from them mandatory.
# spg-config => all the information from the transaction.

=begin

<Script
    src={`https://spg.qly.site1.sibs.pt/assets/js/widget.js?id=${transaction.transactionID}`}
  ></Script>
  <h3>Option 1: Embed Form.</h3>
  <form
    className="paymentSPG"
    spg-context={transaction.formContext}
    spg-config={JSON.stringify({
      paymentMethodList: transaction.paymentMethodList,
      amount: transaction.amount,
      language: "en",
      redirectUrl: `${process.env.NEXT_PUBLIC_SITE_URL}/checkout/sibs`,
      customerData: null,
    })}
  />

=end

### 
# Status
###
# normal response from the status request. in this case there is before the form contact to use one of the options so it will be pending.
# depending on the type of payemnt there will be additional information.
# consult the information from the documentation and the conversation with the SIBS team.

=begin
{
    "merchant": {
        "terminalId": "56795",
        "merchantTransactionId": "teste 12345"
    },
    "transactionID": "s2T3sfBjwny4V5BhcMTP",
    "amount": {
        "currency": "EUR",
        "value": "5.00"
    },
    "paymentType": "PURS",
    "paymentStatus": "Pending",
    "execution": {
        "endTime": "2024-02-05T02:26:20.384Z",
        "startTime": "2024-02-05T02:26:20.301Z"
    },
    "returnStatus": {
        "statusCode": "000",
        "statusMsg": "Success",
        "statusDescription": "Success"
    }
}
=end

=begin
other notes.

- The form will always require human interaction in order to complete the transaction step so testing this will be tough (UI testing)
- I asked them regarding previous transaction that were successful but got no response.
- Pending transactions after some time will be canceled/failed so care with those test cases.

-- testing assets 
https://www.docs.pay.sibs.com/test-and-development-resources/testing-assets/ dont seem to be working out 

-- status
- if the cliend-id / token is different from the generation it will not work on getting the status so if the users change you will have pending forever or misisng info

-- mbway
- associate one of the jumpseller numbers to the account to test the mbway payment method on the qly. required to move from pedning to other status.
=end