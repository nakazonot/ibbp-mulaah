class ShowUserNameOnRegistration < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(
      [
        { name: 'sign_up.require_user_name_input', value: '0', description: 'Require user "Name" input on Sign Up page (1 - yes, 0 - no)'}
      ]
    )
  end
end
