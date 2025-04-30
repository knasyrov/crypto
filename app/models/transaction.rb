class Transaction < ApplicationRecord  
  validates :in_addr, :out_addr, :change_addr, presence: true

  enum state: {
    draft: 0,
    completed: 1,
    error: 2
  }

  belongs_to :in, class_name: 'Address', foreign_key: :in_addr
  belongs_to :change, class_name: 'Address', foreign_key: :change_addr
end
