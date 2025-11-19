class AddUniqueIndexToMacAddr < ActiveRecord::Migration[8.1]
  def change
    add_index :macs, :addr, unique: true
  end
end
