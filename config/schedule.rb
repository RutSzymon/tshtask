# encoding: utf-8
set :output, "#{path}/log/cron.log"

every :weekday, at: "9:00am" do
  runner "RatesWorker.perform_async"
end