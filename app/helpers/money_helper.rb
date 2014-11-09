module MoneyHelper
  def to_currency number
    ("%0.2f" % number + " zł").gsub(".", ",")
  end

  def breadcrumbs
    b = ["#{link_to "Exchanges", money_index_path}"]
    b << ["#{link_to "#{@exchange}", money_path(@exchange)}"] if @exchange
    b << ["#{@currency}"] if @currency
    b.join(" / ").html_safe
  end
end