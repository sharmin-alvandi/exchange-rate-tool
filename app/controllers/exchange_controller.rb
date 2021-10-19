# frozen_string_literal: true

require_relative '../client/exchange_rate'

#  A controller class for currency exchange
class ExchangeController < ApplicationController
  before_action :create_exchange_rate_api_client

  def index
    @currency_types = @client.extract_currency_types
    return @currency_types if @currency_types

    @currency_types = []
    flash[:alert] = 'Timeout Error'
    render action: :index
  end

  def convert
    usd_amount = params[:amount].to_f
    selected_currency_type = params[:currency]

    rate = @client.extract_rate_for(selected_currency_type)
    @calculated_amount = calculate(usd_amount, rate)
  end

  private

  def create_exchange_rate_api_client
    @client = Client::ExchangeRate.new
    return @client unless @client.response_hash.nil?

    @currency_types = []
    flash[:alert] = 'your account has reached the the number of requests allowed by your plan.'
    render action: :index
  end

  def calculate(usd_amount, rate)
    (usd_amount * rate).round(2)
  end
end
