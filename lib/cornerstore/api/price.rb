class Cornerstore::Price < Cornerstore::Model::Base
  attr_accessor :gross,
                :net,
                :tax_rate,
                :currency
                
  validates :gross, numericality: { greater_than_or_equal_to: 0 }
  validates :net, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_rate, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true
                
  def attributes
    {
      gross: gross,
      net: net,
      tax_rate: tax_rate,
      currency: currency
    }
  end
  
  def <=> (other_object)
    case other_object
    when Integer, Float, Fixnum
      other_object <=> self.gross
    when Cornerstore::Price
      other_object.gross <=> self.gross
    else
      raise ArgumentError, "can only compare Integer, Float, Fixnum or Price objects with Price"
    end
  end
  
  def to_f
    self.gross
  end
end