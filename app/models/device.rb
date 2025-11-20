class Device < ApplicationRecord
   has_many :macs

   validates :qr1, presence: false
   validates :qr2, presence: false
   validates :pcb_version, inclusion: 1..99
   validates :product_line, inclusion: (1..99).map { |d| d.to_s.rjust(2, "0") }
   validates :product_group, inclusion: %w[R S A]
   validates :hardware_revision, inclusion: "A".."Z"
   validate :unique_qr1_and_qr2

   before_create :generate_serial_number

   def unique_qr1_and_qr2
      exists = Device.where("(qr1 = :qr1 AND qr2 = :qr2) OR (qr1 = :qr2 AND qr2 = :qr1)", qr1: qr1, qr2: qr2).count > 0

      if exists
         errors.add(:qr1, "The qr1 and qr2 combination must be unique (one already exists)")
         errors.add(:qr2, "The qr1 and qr2 combination must be unique (one already exists)")
      end
   end

   def generate_serial_number
      if !self.serial_number
         serial_digits = (Device.count + 1).to_s.rjust(5, "0")
         week_year = Date.today.strftime("%W%y")
         prod_line = product_line.rjust(2, "0")
         self.serial_number = "MT-#{product_group}#{prod_line}#{hardware_revision}-#{week_year}-#{serial_digits}"
      end
   end

   def self.create_device(attrs, num_macs)
    ActiveRecord::Base.transaction do
      @device = Device.new(attrs)
      if @device.save
        next_macs =  Mac.where(device_id: nil).order(:addr).limit(num_macs)
        Mac.where(id: next_macs.select(:id)).update_all(device_id: @device.id)
      end
      return @device
    end
  end
end
