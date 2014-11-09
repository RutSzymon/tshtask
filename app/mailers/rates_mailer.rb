class RatesMailer < ActionMailer::Base
  default from: "tshtask@gmail.com"

  def updated_rates(exchange)
    @exchange = exchange
    User.find_each do |user|
      mail(to: "#{user.name} <#{user.email}>", subject: "Updated rates") if user.email
    end
  end
end