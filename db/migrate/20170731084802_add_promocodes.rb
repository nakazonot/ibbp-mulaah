class AddPromocodes < ActiveRecord::Migration[5.1]
  def change
    create_table :promo_codes do |t|
      t.string     :promo_code, null: false
      t.timestamps              null: false
      t.datetime :deleted_at,   null: true
    end

    add_reference :users, :promo_code, index: true, foreign_key: true, null: true
    execute "CREATE UNIQUE INDEX index_promo_codes_on_lowercase_promo_code ON promo_codes USING btree (lower(promo_code)) WHERE deleted_at IS NULL;"

  end
end
