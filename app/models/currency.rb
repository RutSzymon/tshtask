class Currency < ActiveRecord::Base
  belongs_to :exchange

  scope :by_code, -> (code) { where(code: code) }

  def self.median(code)
    prices = by_code(code).map(&:mean_price).sort
    size = prices.size
    size % 2 == 1 ? prices[size/2] : (prices[size/2 - 1] + prices[size/2]).to_f / 2
  end

  def self.chart_data(code)
    by_code(code).map{ |rate| { date: rate.date, buy_price: rate.buy_price, sell_price: rate.sell_price } }
  end

  def to_s
    "#{name} (#{code})"
  end

  def mean_price
    ((buy_price + sell_price) / 2).round(2)
  end
end