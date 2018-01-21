class AddTranslationForReferralLinkInConfirmations < ActiveRecord::Migration[5.1]
  def change
    Translation.create(
      locale: 'en',
      key: 'message.confirmation_instructions_html',
      value: '<p>Welcome %{email}!</p><p>You can confirm your account email through the link below:</p><p><a href="%{confirmation_url}">Confirm my account</a></p><p>This is your %{coin_tiker} <a href="%{referral_url}">referral link</a>. You can use it to share the project with your friends and other interested parties. If any of them sign up with this link they will be added to your referral program. Your reward amounts to %{referral_bonus} of all %{coin_tiker} tokens bought by your referrals.</p>',
      interpolations: %w[email confirmation_url coin_tiker referral_url referral_bonus]
    )
  end
end
