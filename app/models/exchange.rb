require "open-uri"

class Exchange < ActiveRecord::Base
  has_many :currencies, -> { order(:id) }, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  before_validation { self.name = xml_name }

  scope :for_today, -> { where(created_at: (Date.today.beginning_of_day..Date.today.end_of_day)) }

  def to_s
    name
  end

  def get_nbp_xml
    @get_nbp_xml ||= open("http://www.nbp.pl/kursy/xml/#{xml_name}.xml").read
  end

  def save_current_rates
    Hash.from_xml(get_nbp_xml)["tabela_kursow"]["pozycja"].map do |rate|
      currencies.new(name: rate["nazwa_waluty"], converter: rate["przelicznik"], code: rate["kod_waluty"],
        buy_price: rate["kurs_kupna"].gsub(",", "."), sell_price: rate["kurs_sprzedazy"].gsub(",", "."),
        date: Date.today)
    end
    self.save
  end

  private
  def xml_list
    open("http://nbp.pl/kursy/xml/dir.txt").read
  end

  def xml_regexp
    /c([0-9]+)z#{Date.today.strftime "%y%m%d"}/
  end

  def xml_name
    @xml_name ||= xml_list.lines.select{ |l| l.match(xml_regexp) }.first[0..-3] rescue nil
  end
end