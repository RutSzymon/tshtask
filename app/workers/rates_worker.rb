class RatesWorker
  include Sidekiq::Worker

  def perform
    unless Exchange.for_today.exists?
      exchange = Exchange.new
      RatesMailer.updated_rates(exchange).deliver if exchange.save_current_rates
    end
  end
end