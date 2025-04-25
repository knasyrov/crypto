class Transaction < ApplicationRecord
  belongs_to :in_addr, class_name: 'Address', foreign_key: :eid
  belongs_to :change_addr, class_name: 'Address', foreign_key: :eid

  validates :in_addr, :out_addr, :change_addr, presence: true
end
