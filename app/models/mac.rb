class Mac < ApplicationRecord
  belongs_to :device, optional: true

  validates :addr, comparison: {
    greater_than_or_equal_to: 0xE8F6D7001000,
    less_than_or_equal_to: 0xE8F6D70FFFFF
  }

  def self.seed(start_addr, end_addr)
    records = (start_addr..end_addr).map do |addr|
      { addr: addr, created_at: Time.current, updated_at: Time.current }
    end

    records.each_slice(10000) do |batch|
      Mac.insert_all(batch)
    end
  end

  def addr_hex
    addr.to_s(16).scan(/\w{2}/).join(":")
  end
end
