class MoneyController < ApplicationController
  rescue_from OpenURI::HTTPError, with: :rescue_message

  def index
    @exchanges = Exchange.all.page(params[:page])
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
    #generate a report for selected currency
    #report should show: basic statistics: mean, median, average
    #also You can generate a simple chart(use can use some js library)

    #this method should be available only for currencies which exist in the database
  end

  private
  def exchange
    @exchange ||= Exchange.find(params[:id])
  end

  def rescue_message
    flash[:alert] = "Rates for today are not available"
    redirect_to money_index_path
  end
end