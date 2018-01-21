namespace :dev do
  desc 'Creates new user account with admin ability'
  task :create_admin, [:email, :password, :password_confirmation] => [:environment] do |task, args|
    ARGV.each { |a| task a.to_sym do ; end }

    user = User.new(email: ARGV[1], name: 'Admin', password: ARGV[2], password_confirmation: ARGV[3], role: User::ROLE_ADMIN, registration_agreement: true)
    user.skip_confirmation!
    user.save

    puts user.errors.present? ? "error: #{user.errors.full_messages.first}" : "Admin created, id: #{user.id}"
  end

  desc "Pregenerate payment addresses for CoinPayments"
  task pregenerate_free_payment_addresses: :environment do
    puts "#{Time.current.to_formatted_s(:db)} INFO: Started task dev:pregenerate_free_payment_addresses"
    begin
      ans = {}
      repeat_count = ([ENV['COIN_PAYMENTS_FREE_ADDRESS_POOL'].to_f, ENV['ANY_PAY_COINS_FREE_ADDRESS_POOL'].to_f].max / 10).ceil
      repeat_count.times do |n|
        result = Services::PaymentAddress::FreePaymentAddressGenerator.new(nil, 10, true).call
        result.each do |currency, amount|
          ans[currency] = { count_generated: 0, total_count: 0 } if ans[currency].blank?
          ans[currency][:count_generated] += amount
        end
      end

      Parameter.available_currencies.except(ExchangeRate::DEFAULT_CURRENCY).keys.each do |currency|
        ans[currency] = { count_generated: 0, total_count: 0 } if ans[currency].blank?
        ans[currency][:total_count] = PaymentAddress.by_currency(currency).count
      end
      ans.each do |currency, value|
        puts "#{currency} - #{value[:count_generated]} addresses generated, total #{value[:total_count]} addresses"
      end
      puts "#{Time.current.to_formatted_s(:db)} INFO: Finished task dev:pregenerate_free_payment_addresses"
    rescue EOFError
      puts "Payment service currently unavailable. Please try again."
    end
  end

  desc "Generate test users"
  task :generate_test_users, [:email_template, :password] => [:environment] do |task, args|
    ARGV.each { |a| task a.to_sym do ; end }
    raise "\nEnter email_template" if ARGV[1].blank?
    raise "\nEnter test password" if ARGV[2].blank?

    wallet_prefix = ARGV[1].split('@').first

    1000.times do |n|
      user = User.new(email: ARGV[1].gsub('@', "#{n+1}@"), password: ARGV[2], eth_wallet: "test_wallet_#{wallet_prefix}#{n}", role: User::ROLE_USER)
      user.skip_confirmation!
      user.save
      puts user.errors.present? ? "error: #{user.errors.full_messages.first}" : "#{user.email} created, id: #{user.id}"
    end
    puts 'done'
  end

  task add_system_field_for_payments: :environment do
     # находим системные балансовые платежи
    Payment.by_type(Payment::PAYMENT_TYPE_BALANCE).where(transaction_id: nil).where(created_by_user_id: nil).order(:id).find_each(batch_size: 100).each do |payment|
      payment.update_column(:system, true)
    end
     # находим списания, при которых не куплены токены
    Payment.by_type(Payment::PAYMENT_TYPE_PURCHASE).where(iso_coin_amount: 0).where(created_by_user_id: nil).order(:id).find_each(batch_size: 100).each do |payment|
      payment.update_column(:system, true)
    end
    puts 'done'
  end

  task add_environment: :environment do
  end

  desc "The validation of parameters before the system's release"
  task :self_check do
    begin
      Rake::Task["dev:add_environment"].invoke
    rescue
      false
    end

    errors = Services::SystemInfo::ValidateParams.new.call
    sections = {
      env:        'ENV params',
      ico_params: 'ICO params',
      ico_stages: 'ICO stages',
      systems:    'Systems'
    }

    sections.each do |section, section_name|
      puts "","#{section_name}:"
      errors[section].each do |key, value|
        error = value.first
        if error.blank?
          puts "#{key} - OK".green
        elsif error[:error_type] == Services::SystemInfo::ValidateParams::ERROR_TYPE_ERROR
          puts "#{key} - ERROR: #{error[:message]}".red
        elsif error[:error_type] == Services::SystemInfo::ValidateParams::ERROR_TYPE_WARNING
          puts "#{key} - WARNING: #{error[:message]}".yellow
        end
      end
    end

    puts "","Free payment adresses:"
    Parameter.available_currencies.except(ExchangeRate::DEFAULT_CURRENCY).keys.each do |currency|
      puts "#{currency} - #{PaymentAddress.by_currency(currency).not_user.count} free payment adresses"
    end
  end

  desc "Send test email. Example: rake dev:send_test_mail_to[example@example.com]"
  task :send_test_mail_to, [:email] => [:environment] do |task, args|
    raise "\nEnter email" if args[:email].blank?

    TestMailer.test_mail(args[:email]).deliver_later
    puts "Done. Please check email at #{args[:email]}"
  end
end
