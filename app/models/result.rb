class Result < ApplicationRecord
  belongs_to :objective

  has_many :indicator#, dependent: :destroy

  validates_presence_of :objective
end
