class Transaction < ApplicationRecord
  #validates :in_value, :out_value, presence: true

  #validates :in_value, numericality: { greater_than: 0, less_than_or_equal_to: 30.0 }
end
