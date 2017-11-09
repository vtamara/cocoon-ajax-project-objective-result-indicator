class Objective < ApplicationRecord
  belongs_to :project

  has_many :results#, dependent: :destroy
end
