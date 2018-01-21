class DeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions_register_from_admin
    Devise::Mailer.reset_password_instructions_register_from_admin(User.first, SecureRandom.hex(8), {})
  end

  def confirmation_instructions
    Devise::Mailer.confirmation_instructions(User.first, SecureRandom.hex(8), {})
  end

  def unlock_instructions
    Devise::Mailer.unlock_instructions(User.first, SecureRandom.hex(8))
  end
end
