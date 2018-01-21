class AddSignUpReferralsTranslation < ActiveRecord::Migration[5.1]
  def change
    Translation.create(
      locale: 'en',
      key: 'registration.not_referral_follower_signup_error',
      value: 'Only referral link followers can sign up',
      interpolations: nil
    )
  end
end
