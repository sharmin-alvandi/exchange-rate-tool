# frozen_string_literal: true

require 'net/http'
require 'json'

module Client
  #  A client for handling the calls to Exchangerate-api
  class ExchangeRate
    API_VERSION = 'v6'
    BASE_CURRENCY_TYPE = 'USD'
    BASE_URL = 'exchangerate-api.com'

    attr_reader :response_hash

    def initialize
      @response_hash = exchange_rates
    end

    def extract_currency_types
      @response_hash.dig('conversion_rates')&.keys
    end

    def extract_rate_for(currency_type)
      @response_hash.dig('conversion_rates', currency_type)
    end

    private

    def exchange_rates
      Rails.cache.fetch('exchange_rates', expires_in: 12.hours) do
        return nil if quota_reached?

        request_endpoint(url)
      end
    end

    def api_key
      ENV['EXCHANGE_RATE_API_KEY']
    end

    def url
      url ||= "https://#{API_VERSION}.#{BASE_URL}/#{API_VERSION}/"\
              "#{api_key}/latest/#{BASE_CURRENCY_TYPE}"
    end

    def request_endpoint(url)
      uri = URI(url)
      response = handle_timeouts { Net::HTTP.get(uri) }

      JSON.parse(response)
    end

    def handle_timeouts
      yield
    rescue Net::OpenTimeout, Net::ReadTimeout
      {}
    end

    def quota_reached?
      url_for_quota_status = "https://#{API_VERSION}.#{BASE_URL}/#{API_VERSION}/#{api_key}/quota"
      result_hash = request_endpoint(url_for_quota_status)
      !result_hash.dig('requests_remaining').positive?
    end
  end
end
