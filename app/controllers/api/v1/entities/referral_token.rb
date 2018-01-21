class API::V1::Entities::ReferralToken < API::V1::Entities::Base
  expose :id,                     documentation: { type: 'Integer'  }
  expose :email,                  documentation: { type: 'String'   }
  expose :bounty_amount,          documentation: { type: 'Float'    }
  expose :referral_level,         documentation: { type: 'Integer'  }
  expose :created_at,   format_with: :api_datetime, documentation: { type: 'Datetime' }
  expose :confirmed_at, format_with: :api_datetime, documentation: { type: 'Datetime' }
end
