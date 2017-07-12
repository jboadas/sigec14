class Cabvuelo < ActiveRecord::Base
  belongs_to :cabequipo
  has_many :cabpasajeros
end
