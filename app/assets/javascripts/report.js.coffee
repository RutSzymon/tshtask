ready = ->
  if $("#chart").length != 0
    Morris.Line(
      element: "chart"
      data: gon.currency_rates
      xkey: "date"
      ykeys: ["buy_price", "sell_price"]
      labels: ["Buy price", "Sell price"]
      ymin : gon.min_value
      ymax : gon.max_value
      postUnits: " zł"
    )

$(document).ready(ready)
$(document).on("page:load", ready)