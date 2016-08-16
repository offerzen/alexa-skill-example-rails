class StockService

  class << self

    def stock_price(params)
      stock = params['request']['intent']['slots']['Stock']['value']

      stock = stock.downcase if stock.present?

      case stock
      when 'apple'
        result = StockService.get_stock('NASDAQ:AAPL')
        value = result['l_fix']

        output = "The stock price for apple is #{value} in United States Dollars."

      when 'google'
        result = StockService.get_stock('NASDAQ:GOOGL')
        value = result['l_fix']

        output = "The stock price for google is #{value} in United States Dollars."

      when 'standard bank'
        result = StockService.get_stock('JSE:SBK')
        value = result['l_fix']

        output = "The stock price for standard bank is #{value} in South African Cents."

      else
        output = "I'm not familiar with #{stock}."
      end

      output
    end

    def get_stock(query)
      url = "https://www.google.com/finance/info?q=#{query}"

      # Response needs to be clipped
      response = RestClient.get(url)
      response = response[6, response.length - 9]

      result = JSON.parse(response)
    end

  end
end
