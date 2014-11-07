require 'spec_helper'

describe Exchange do
  EXCHANGE_COLUMNS = %w[name created_at updated_at]

  describe "via relations" do
    it { should have_many(:currencies).dependent(:destroy) }
  end

  describe "via validations" do
    before(:each) do
      @exchange = FactoryGirl.build(:exchange)
    end

    it { @exchange.should be_valid }

    it "should validate presence of name" do
      Timecop.freeze(Date.tomorrow) do
        @exchange.should_not be_valid
        @exchange.errors.messages.should eq({ name: ["can't be blank"] })
      end
    end

    it "should validate uniqueness of name - can't create 2 exchanges the same day" do
      @exchange.save
      exchange2 = FactoryGirl.build(:exchange)
      exchange2.should_not be_valid
      exchange2.errors.messages.should eq({ name: ["has already been taken"] })
    end
  end

  describe "via callbacks" do
    before(:each) do
      @exchange = FactoryGirl.build(:exchange)
      Timecop.freeze(Date.today.beginning_of_week + 10.hours)
    end

    after(:each){ Timecop.return }

    context "before validation" do
      it "should set xml's name as own name" do
        @exchange.name.should eq(nil)
        @exchange.valid?
        @exchange.name.should eq(@exchange.send(:xml_name))
      end
    end
  end

  describe "via scopes" do
    context ".for_today" do
      it "should return exchanges for today" do
        Timecop.freeze(Date.today.beginning_of_week + 10.hours) do
          @yesterday_exchange = FactoryGirl.create(:exchange)
        end
        Timecop.freeze(Date.today.beginning_of_week + 1.day + 10.hours) do
          @today_exchange = FactoryGirl.create(:exchange)
          Exchange.for_today.should include(@today_exchange)
          Exchange.for_today.should_not include(@yesterday_exchange)
        end
        Timecop.freeze(Date.today.beginning_of_week + 10.hours) do
          Exchange.for_today.should include(@yesterday_exchange)
          Exchange.for_today.should_not include(@today_exchange)
        end
      end
    end
  end

  describe "via instance methods" do
    before(:each) do
      @exchange = FactoryGirl.build(:exchange)
      Timecop.freeze(Date.today.beginning_of_week + 10.hours)
    end

    after(:each){ Timecop.return }

    context "#get_nbp_xml" do
      it "should return xml with rates for today" do
        @exchange.get_nbp_xml.strip[/\A<\?xml/].should_not be_nil
        Hash.from_xml(@exchange.get_nbp_xml)["tabela_kursow"]["data_publikacji"].should eq(Date.today.to_s)
      end

      it "should raise error if xml for today doesn't exist" do
        Timecop.freeze(Date.today.beginning_of_week - 1.day) do
          expect { @exchange.get_nbp_xml }.to raise_error(OpenURI::HTTPError, "404 Not Found")
        end
      end
    end

    context "#save_current_rates" do
      it "should save self rates for every currency" do
        @exchange.save_current_rates
        @exchange.persisted?.should eq(true)
        @exchange.currencies.size.should eq(13)
        @exchange.currencies.all?(&:valid?).should eq(true)
      end
    end
  end

  describe "DB columns" do
    EXCHANGE_COLUMNS.each do |c|
      it "should include '#{c}'" do
        Exchange.column_names.should include(c)
      end
    end
  end
end