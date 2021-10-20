# frozen_string_literal: true

require_relative '../client/exchange_rate'

#  A controller class for currency exchange
class ExchangeController < ApplicationController
  before_action :exchange_rate_api_client

  def index
    @currency_types = @client.extract_currency_types
  end

  def convert
    usd_amount = params[:amount].to_f
    selected_currency_type = params[:currency]

    rate = @client.extract_rate_for(currency_type: selected_currency_type)
    @calculated_amount = calculate(usd_amount, rate)
  end

  private

  def exchange_rate_api_client
    @client = validate_client(Client::ExchangeRate.new)
  end

  def validate_client(client)
    return client unless client.response_hash['alert']

    @currency_types = []
    flash[:alert] = client.response_hash['alert']
    render action: :index
  end

  def calculate(usd_amount, rate)
    (usd_amount * rate).round(2)
  end
end
