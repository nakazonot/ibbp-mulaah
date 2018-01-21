class AddTranslatinsAutoconvertNotes < ActiveRecord::Migration[5.1]
  def change
    Translation.create(
      locale: 'en',
      key: 'main.step.make_deposit.note_autoconvert_off_html',
      value: '<p>Please note that deposit of funds is not a purchase of MYTOKEN tokens. You need to complete Step 3 and purchase the required number of tokens with the deposited funds.</p>'.html_safe,
    )

    Translation.create(
      locale: 'en',
      key: 'main.step.make_deposit.note_autoconvert_on_html',
      value: '<p>Please note that the purchase of MYTOKEN tokens with the deposited funds is completed automatically, so you can skip Step 3.</p>'.html_safe,
    )
  end
end
