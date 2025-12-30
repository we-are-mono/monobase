class AddPackagedDateToDevice < ActiveRecord::Migration[8.1]
  def change
    add_column :devices, :packaged_date, :datetime
  end
end
