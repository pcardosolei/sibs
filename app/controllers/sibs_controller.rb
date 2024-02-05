require 'net/http'
require 'json'
require 'date'
require 'dotenv'

Dotenv.load 


# API logic
# https://www.pay.sibs.com/docs/sibs-gateway/
#
# API parameters
# https://developer.sibsapimarket.com/sandbox/node/3085

class SibsController < ApplicationController

  def transaction 
    today = Date.today
    days_from_now = today + 2

    body = {
      merchant: {
        terminalId: ENV['TERMINAL_ID'].to_i,
        channel: "web",
        merchantTransactionId: "OrderId - def32a",
      },
      transaction: {
        transactionTimestamp: DateTime.now, # DateTime.now.iso8601
        description: "Transaction test by SIBS",
        moto: false,
        paymentType: "PURS",
        amount: {
          value: 5.5,
          currency: "EUR",
        },
        paymentMethod: ["CARD", "MBWAY", "REFERENCE"],
        paymentReference: {
          initialDatetime: DateTime.now,
          finalDatetime: (DateTime.now + 2),
          maxAmount: {
            value: 5.5,
            currency: "EUR",
          },
          minAmount: {
            value: 5.5,
            currency: "EUR",
          },
          entity: ENV['ENTITY'],
        },
      },
    }.to_json

    uri = URI.parse(ENV['SIBS_URL'])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, {
      'Authorization' => "Bearer #{ENV['SIBS_TOKEN']}",
      'X-IBM-Client-Id' => ENV['SIBS_CLIENT_ID'] || "",
      'Content-Type' => 'application/json'
    })
    request.body = body

    response = http.request(request)
    data = JSON.parse(response.body)

    render :json => data
  end

  def status
    id = params[:id]
    return if id.nil?

    uri = URI.parse("#{ENV['SIBS_URL']}/#{id}/status")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri, {
      'Authorization' => "Bearer #{ENV['SIBS_TOKEN']}",
      'X-IBM-Client-Id' => ENV['SIBS_CLIENT_ID'] || ""
    })
  
    response = http.request(request)
    data = JSON.parse(response.body)
    
    render :json => data
  end
end

