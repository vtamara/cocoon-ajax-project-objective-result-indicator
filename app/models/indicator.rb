class Indicator < ApplicationRecord
  belongs_to :result
  
  validates_presence_of :result
end
