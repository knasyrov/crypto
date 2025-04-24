class Transaction < ApplicationRecord
  validates :in_addr, :out_addr, :change_addr, presence: true
end
