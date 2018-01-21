class UpdateTranslationAutoconvert < ActiveRecord::Migration[5.1]
  def change
    translation = Translation.find_by(key: 'main.step.make_deposit.note_autoconvert_on_html')
    translation.value = '<p>Please note that if your balance is sufficient for the minimum purchase, the purchase of MYTOKEN tokens with the deposited funds is completed automatically, and you skip Step 3.</p>'
    translation.save
  end
end
