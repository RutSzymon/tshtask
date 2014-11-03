# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :currency do
    name "MyString"
    converter 1
    code "MyString"
    buy_price 1.5
    sell_price 1.5
    exchange nil
  end
end
