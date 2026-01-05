class ChangePcbVersionToString < ActiveRecord::Migration[8.1]
  def change
    change_column :devices, :pcb_version, :string
  end
end
