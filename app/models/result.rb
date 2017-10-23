class Result < ApplicationRecord
  belongs_to :objective

  validates_presence_of :objective
end
