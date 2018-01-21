class API::V1::Entities::KycVerification < API::V1::Entities::Base
  expose :first_name,              documentation: { type: 'String' }
  expose :middle_name,             documentation: { type: 'String' }
  expose :last_name,               documentation: { type: 'String' }
  expose :phone,                   documentation: { type: 'String' }
  expose :address_line_1,          documentation: { type: 'String' } do |kyc_verification|
    kyc_verification.address['address_line_1'] if kyc_verification.address.present?
  end
  expose :address_line_2,          documentation: { type: 'String' } do |kyc_verification|
    kyc_verification.address['address_line_2'] if kyc_verification.address.present?
  end
  expose :address_line_3,          documentation: { type: 'String' } do |kyc_verification|
    kyc_verification.address['address_line_3'] if kyc_verification.address.present?
  end
  expose :country_code,            documentation: { type: 'String' }
  expose :city,                    documentation: { type: 'String' }
  expose :state,                   documentation: { type: 'String' }
  expose :citizenship,             documentation: { type: 'String' }
  expose :gender,                  documentation: { type: 'String' }
  expose :dob,                     documentation: { type: 'Date'   }, format_with: :api_date
  expose :document_number,         documentation: { type: 'String' }
  expose :kyc_verification,       documentation: { type: 'String'  } do |kyc_verification|
    kyc_verification.status
  end
  expose :kyc_verified_at,        documentation: { type: 'String'  }, format_with: :api_datetime do |kyc_verification|
    kyc_verification.verified_at
  end
  expose :deny_reason,             documentation: { type: 'String' }
end
