require "open-uri"

class Exchange < ActiveRecord::Base
  has_many :currencies, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  before_validation { self.name = xml_name }

  def get_nbp_xml
    @get_nbp_xml ||= open("http://www.nbp.pl/kursy/xml/#{xml_name}.xml").read
  end

  def save_current_rates
    self.save
    rates = Hash.from_xml(get_nbp_xml)["tabela_kursow"]["pozycja"].map do |rate|
      Currency.new(name: rate["nazwa_waluty"], converter: rate["przelicznik"], code: rate["kod_waluty"],
        buy_price: rate["kurs_kupna"], sell_price: rate["kurs_sprzedazy"], exchange: self)
    end
    Currency.import rates
  end

  private
  def xml_list
    open("http://nbp.pl/kursy/xml/dir.txt").read
  end

  def xml_name
    xml_list.lines.select{ |l| l.match(/c([0-9]+)z#{Date.today.strftime "%y%m%d"}/) }.first[0..-3] rescue nil
  end
end