namespace :cpa_postback do
  desc 'Add new postback to DB.'
  task :create, [:action, :postback_uri, :labels] => [:environment] do |task, args|
    postback = CpaPostback.create(
      action:       args[:action],
      postback_uri: args[:postback_uri],
      labels:       args[:labels].present? ? JSON.parse(args[:labels]) : {}
    )

    puts postback.errors.present? ? "Errors: #{postback.errors.full_messages}" : "CPA postback added, ID ##{postback.id}"
  end
end
