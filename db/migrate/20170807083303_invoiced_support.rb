class InvoicedSupport < ActiveRecord::Migration[5.1]
  def change
    create_table :invoice_customers do |t|
      t.references :user, index: true, foreign_key: true
      t.string   :full_name, null: false
      t.string   :phone,     null: true
      t.string   :bank,      null: true

      t.string   :country, null: true
      t.string   :state, null: true
      t.string   :postal_code, null: true
      t.string   :city, null: true
      t.string   :address, null: true

      t.integer  :external_id, null: false
      t.string   :number, null: false

      t.timestamps              null: false
    end

    create_table :invoices do |t|
      t.references :invoice_customer, index: true, foreign_key: true
      t.float      :amount,         null: false
      t.integer    :external_id,    null: false
      t.string     :number,         null: false
      t.string     :payment_terms,  null: true
      t.datetime   :due_at,         null: true

      t.timestamps null: false
    end
  end
end
