# Exchange Rate Tool
A simple currency exchange rate tool using an API
(https://open.exchangerate-api.com/v6/latest)

## Hypothetical Business Background
Insurance brokers often receive quotes with premium value and coverage value in multiple
currencies. Sometimes the brokers may not be familiar with the foreign currency and want to
quickly convert the foreign exchange to their preferred currency. Therefore, we are looking to
add a simple currency exchange widget to the product to do so. This is an exploratory feature to
help us evaluate market adoption and we can treat it as an MVP feature.

## Requirements
1. User should be able to input a dollar amount and select a currency type to be converted
from
2. User should be able to select a currency type to be converted to and the widget should
display the resulting amount
3. System should not trigger the rate limits imposed by the open API
4. Don’t worry about adding authentication to the API. Feel free to keep it open for the
purpose of this exercise

## Approach
Class `ExchangeRate` is a client for the [**exchangerate-api**](https://www.exchangerate-api.com/). which is responsible for the whole process of fetching and caching data from the API. To follow _Single Responsiblity_ principle I could have moved the caching operation to a separate cache-specific class. Obviously if caching was going to be widely used, it would be better to have its own class. But for now decided not to do so as it's only a single fetch at the moment.

`ExchangeController` has two methods of `index` and `convert`. It gets the list of currency types and the rate for selected currency type from the `ExchangeRate` client to pass to the corresponding views.
### Making Requests and Request Limits
- Used [Net::Http](https://github.com/ruby/net-http) to make http requests.
- Used the [ExchangeRate-API documentation](https://www.exchangerate-api.com/docs/overview) to learn about:
  - [API Endpoints and the standard response](https://www.exchangerate-api.com/docs/standard-requests)
  - [API Request Quota](https://www.exchangerate-api.com/docs/request-quota-endpoint) endpoint and response
  - [Ruby Exchange Api Documentation](https://www.exchangerate-api.com/docs/ruby-currency-api)
  - free plan which has a **daily** update and allows 1.5K API Requests p/m
  - Getting free API key

### Caching
Used [low-level caching](https://guides.rubyonrails.org/caching_with_rails.html#low-level-caching) with a TTL of 24 hours as it updates once a day for the free plan. (Might 12 hours as TTL be safer? As it's not clear to me what time of a day it gets the update so in case of a 24 hours TTL, it's possible to have stale data for a couple of hours. 🤔)

### Error Handling
Rescued the following errors:
- Net::OpenTimeout
- Net::ReadTimeout
- Tried to avoid triggering the request limit by checking the remaining requests status before each request and providing an alert to the user.

<!--### User Interface
I'm in the process of learning React and I will complete this project with React regardless of the result of the interview process.

#### Special Thanks to Relay Platform for providing me with the learning opportunity by means of  working on this assignment. Would greatly appreciate the code reviewer(s) gift of feedback.-->
