# frozen_string_literal: true

require 'net/http'
require 'json'

module Client
  #  A client for handling the calls to Exchangerate-api
  class ExchangeRate
    API_VERSION = 'v6'
    BASE_CURRENCY_TYPE = 'USD'
    BASE_URL = 'exchangerate-api.com'

    QUOTA_ALERT = 'your account has reached the number of requests allowed by your plan.'
    TIMEOUT_ALERT = 'Timeout Error'

    attr_reader :response_hash

    def initialize
      @response_hash = exchange_rates
    end

    def extract_currency_types
      @response_hash['conversion_rates'].keys
    end

    def extract_rate_for(currency_type:)
      @response_hash.dig('conversion_rates', currency_type)
    end

    private

    def exchange_rates
      Rails.cache.fetch('exchange_rates', expires_in: 24.hours) do
        @requests_remaining = requests_remaining_status
        return @requests_remaining if @requests_remaining['alert']

        request_endpoint(url)
      end
    end

    def requests_remaining_status
      url_for_quota_status = "https://#{API_VERSION}.#{BASE_URL}/#{API_VERSION}/#{api_key}/quota"
      status = request_endpoint(url_for_quota_status)
      return status unless status['requests_remaining']

      quantity = status['requests_remaining']
      @requests_remaining = { remaining: quantity }
      return { 'alert' => QUOTA_ALERT } if quantity == 0

      @requests_remaining
    end

    def api_key
      ENV['EXCHANGE_RATE_API_KEY']
    end

    def url
      "https://#{API_VERSION}.#{BASE_URL}/#{API_VERSION}/"\
      "#{api_key}/latest/#{BASE_CURRENCY_TYPE}"
    end

    def request_endpoint(url)
      uri = URI(url)
      response = handle_timeouts { Net::HTTP.get(uri) }
      return response if response['alert']

      JSON.parse(response)
    end

    def handle_timeouts
      yield
    rescue Net::OpenTimeout, Net::ReadTimeout
      { 'alert' => TIMEOUT_ALERT }
    end
  end
end
