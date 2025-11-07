class CreateDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :devices do |t|
      t.string :serial_number
      t.string :qr1
      t.string :qr2
      t.string :product_group
      t.string :product_line
      t.string :hardware_revision
      t.integer :pcb_version

      t.timestamps
    end
  end
end
