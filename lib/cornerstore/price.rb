class Cornerstore::Price < Cornerstore::Base
  attr_accessor :gross,
                :net,
                :tax_rate,
                :currency
end