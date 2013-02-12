class Cornerstore::Price < Cornerstore::Base
  include ActiveModel::Validations

  attr_accessor :gross,
                :net,
                :tax_rate,
                :currency
                
  validates :gross, numericality: { greater_than_or_equal_to: 0 }
  validates :net, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_rate, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, :presence => true
                
  def attributes
    {
      gross: gross,
      net: net,
      tax_rate: tax_rate,
      currency: currency
    }
  end
end