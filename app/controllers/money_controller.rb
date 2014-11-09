class MoneyController < ApplicationController
  rescue_from OpenURI::HTTPError, with: :rescue_message

  def index
    @exchanges = Exchange.order("id desc").page(params[:page])
  end

  def show
    @currencies = exchange.currencies
  end

  def refresh_rates
    if Exchange.for_today.exists? then flash[:notice] = "Rates are already up to date"
    elsif Exchange.new.save_current_rates then flash[:notice] = "Rates have been updated successfully"
    else flash[:alert] = "Something went wrong"
    end
    redirect_to money_index_path
  end

  def report
    @exchange = currency.exchange
    @median = Currency.median(currency.code)
    @buy_average, @sell_average = currency_rates.average(:buy_price), currency_rates.average(:sell_price)
    gon.currency_rates = Currency.chart_data(currency.code)
    gon.min_value = currency_rates.pluck(:buy_price).min.round(2) - 0.01
    gon.max_value = currency_rates.pluck(:sell_price).max.round(2) + 0.01
  end

  private
  def exchange
    @exchange ||= Exchange.find(params[:id])
  end

  def currency
    @currency ||= Currency.find(params[:id])
  end

  def currency_rates
    @currency_rates ||= Currency.by_code(currency.code)
  end

  def rescue_message
    flash[:alert] = "Rates for today are not available"
    redirect_to money_index_path
  end
end