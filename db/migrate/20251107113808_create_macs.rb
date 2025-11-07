class CreateMacs < ActiveRecord::Migration[8.1]
  def change
    create_table :macs do |t|
      t.integer :addr
      t.references :device, null: true, foreign_key: true

      t.timestamps
    end
  end
end
