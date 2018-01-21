class AddPromocodeOnetimeField < ActiveRecord::Migration[5.1]
  def change
    add_column :promocodes, :is_onetime, :boolean, default: false
  end
end
