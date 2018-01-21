every 1.hours do
  rake 'currency:update_currency_rate RAILS_ENV=production', environment: :production
end

every 1.days do
  rake 'currency:sync_available_currencies', environment: :production
  rake 'db:sessions:trim', environment: :production
end

every 6.hours do
  rake 'kyc:update_kyc_verification_status', environment: :production
end
