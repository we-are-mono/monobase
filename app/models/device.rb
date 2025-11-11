class Device < ApplicationRecord
   has_many :macs

   validates :product_group, :inclusion => %w[R S A]
   validates :product_line, :inclusion => (1..99).map {|d| d.to_s.rjust(2, "0") }
   validates :hardware_revision, :inclusion => 'A'..'Z'
   validates :pcb_version, :inclusion => 1..99

   before_save :generate_serial_number

   def generate_serial_number
      if !self.serial_number
         serial_digits = (Device.count + 1).to_s.rjust(5, "0")
         week_year = Date.today.strftime("%W%y")
         prod_line = product_line.rjust(2, "0")
         self.serial_number = "MT-#{product_group}#{prod_line}#{hardware_revision}-#{week_year}-#{serial_digits}"
      end
   end
end