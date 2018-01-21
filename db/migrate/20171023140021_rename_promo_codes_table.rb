class RenamePromoCodesTable < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :promo_code_id, :promo_code_id_OBSOLETE
    rename_table :promo_codes, :promo_codes_OBSOLETE
  end
end
