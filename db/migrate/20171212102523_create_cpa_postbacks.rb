class CreateCpaPostbacks < ActiveRecord::Migration[5.1]
  def change
    create_table :cpa_postbacks do |t|
      t.string :action
      t.string :postback_uri
      t.json   :labels

      t.timestamps
    end
  end
end
