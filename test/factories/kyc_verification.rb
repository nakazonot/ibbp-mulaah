FactoryGirl.define do
  gender  = [KycGenderType::MALE, KycGenderType::FEMALE].sample
  address = {
    address_line_1: Faker::Address.street_name,
    address_line_2: Faker::Address.street_address,
    address_line_3: Faker::Address.secondary_address
  }

  factory :kyc_verification do
    status          KycStatusType::DRAFT
  end

  factory :kyc_verification_filled, parent: :kyc_verification do
    first_name      Faker::Name.first_name
    middle_name     Faker::Name.prefix
    last_name       Faker::Name.last_name
    phone           Faker::PhoneNumber.cell_phone
    address         address
    gender          gender
    citizenship     Faker::Address.country_code
    state           Faker::Address.state
    city            Faker::Address.city
    country_code    Faker::Address.country_code
    dob             Faker::Date.birthday
    document_number Faker::Number.number(10)
  end
end
