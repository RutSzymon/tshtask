require 'spec_helper'

describe Currency do
  CURRENCY_COLUMNS = %w[name converter code buy_price sell_price date exchange_id]

  describe "via relations" do
    it { should belong_to(:exchange) }
  end

  describe "via validations" do
    before(:each) do
      Timecop.freeze(Date.today.beginning_of_week + 10.hours)
      @currency = FactoryGirl.build(:currency)
    end

    after(:each){ Timecop.return }

    it { @currency.should be_valid }
  end

  describe "via scopes" do
    context ".by_code" do
      it "should return all currencies with given code" do
        Timecop.freeze(Date.today.beginning_of_week + 10.hours) do
          Exchange.new.save_current_rates
        end
        Timecop.freeze(Date.today.beginning_of_week + 1.day + 10.hours) do
          Exchange.new.save_current_rates
        end
        Currency.by_code("USD").size.should eq(2)
        Currency.by_code("USD").all?{ |c| c.code.eql?("USD") }.should eq(true)
      end
    end
  end

  describe "via class methods" do
    before(:each) do
      3.times{ |i| c = FactoryGirl.build(:currency, code: "USD", exchange: nil, buy_price: i + 1, sell_price: i + 1); c.save(validate: false) }
    end

    context ".median" do
      it "should return median of currencies with given code" do
        Currency.median("USD").should eq(2)

        c = FactoryGirl.build(:currency, code: "USD", exchange: nil, buy_price: 4, sell_price: 4); c.save(validate: false)
        Currency.median("USD").should eq(2.5)

        c = FactoryGirl.build(:currency, code: "EUR", exchange: nil, buy_price: 5, sell_price: 5); c.save(validate: false)
        Currency.median("USD").should eq(2.5)
        Currency.median("EUR").should eq(5)
      end
    end

    context ".chart_data" do
      it "should return currencies with given code in format supported by morris.js" do
        Currency.chart_data("USD").first.should eq({ date: nil, buy_price: 1, sell_price: 1 })
        Currency.chart_data("USD").last.should eq({ date: nil, buy_price: 3, sell_price: 3 })
      end
    end
  end

  describe "via instance methods" do
    context "#mean_price" do
      before(:each){ Timecop.freeze(Date.today.beginning_of_week + 10.hours) }

      after(:each){ Timecop.return }

      it "should return mean of buy_price and sell_price" do
        currency = FactoryGirl.build(:currency, buy_price: 2.94, sell_price: 3.00)
        currency.mean_price.should eq(2.97)
      end
    end
  end

  describe "DB columns" do
    CURRENCY_COLUMNS.each do |c|
      it "should include '#{c}'" do
        Currency.column_names.should include(c)
      end
    end
  end
end