class Address < ApplicationRecord
  self.primary_key = :eid
  default_scope { order(path: :asc) }

  validates :eid, :wif, uniqueness: true

  has_many :in_transactions, class_name: 'Transaction', foreign_key: :in_addr 
end
