class API::V1::Entities::User < API::V1::Entities::Base
  expose :id,                     documentation: { type: 'Integer' }
  expose :email,                  documentation: { type: 'String'  }
  expose :name,                   documentation: { type: 'String'  }
  expose :middle_name,            documentation: { type: 'String'  }
  expose :last_name,              documentation: { type: 'String'  }
  expose :name,                   documentation: { type: 'String'  }
  if Parameter.eth_wallet_enabled?
    expose :eth_wallet,           documentation: { type: 'String'  }
  end
  if Parameter.btc_wallet_enabled?
    expose :btc_wallet,           documentation: { type: 'String'  }
  end
  expose :phone,                  documentation: { type: 'String'  }
  expose :referral_uuid,          documentation: { type: 'String'  }
  expose :otp_required_for_login, documentation: { type: 'Boolean' } do |user|
    user.otp_required_for_login.to_b
  end
  expose :is_referral,            documentation: { type: 'Boolean' } do |user|
    user.is_referral?
  end
  expose :confirmed_at, format_with: :api_datetime, documentation: { type: 'Datetime' }
  expose :uses_default_password,  documentation: { type: 'Boolean' }
  expose :kyc_verification,       documentation: { type: 'String'  } do |user|
    user.kyc_verification&.status
  end
  expose :kyc_verified_at,        documentation: { type: 'String'  }, format_with: :api_datetime do |user|
    user.kyc_verification&.verified_at
  end
end
