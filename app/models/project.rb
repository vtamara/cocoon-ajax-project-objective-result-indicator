class Project < ApplicationRecord
  has_many :objectives, dependent: :destroy, validate: true
  has_many :results, through: :objectives
  has_many :indicators, through: :results
  accepts_nested_attributes_for :objectives, allow_destroy: true,
    reject_if: :all_blank
  accepts_nested_attributes_for :results, allow_destroy: true,
    reject_if: :all_blank
  accepts_nested_attributes_for :indicators, allow_destroy: true,
    reject_if: :all_blank
end
