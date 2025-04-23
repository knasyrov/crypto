class Currency < ApplicationRecord
  has_many :rates

  def rate
    rates.order(created_at: :asc).last
  end
end
