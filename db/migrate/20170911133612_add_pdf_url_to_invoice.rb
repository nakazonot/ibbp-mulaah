class AddPdfUrlToInvoice < ActiveRecord::Migration[5.1]
  def change
    add_column :invoices, :pdf_url, :string
  end
end
