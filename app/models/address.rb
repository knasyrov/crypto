class Address < ApplicationRecord
  self.primary_key = :eid

  validates :eid, :wif, uniq: true
  validates [:eid, :path], uniq: true
end
