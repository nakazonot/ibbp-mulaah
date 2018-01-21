class Services::Users::ImportCsv

  USERS_FILE_CONTENT_TYPE = [
    'text/csv',
    'text/comma-separated-values',
    'application/csv',
    'application/excel',
    'application/vnd.ms-excel',
    'application/vnd.msexcel',
    'text/anytext',
    'text/plain'
  ]

  USERS_FILE_PATH         = "docs/"
  USERS_FILE_NAME         = "users.csv"
  USERS_UPLOAD_LIMIT      = 1000

  def initialize(csv_file)
    @csv_file = csv_file
  end

  def call
    temp_dir      = Rails.root.join('tmp', USERS_FILE_PATH)
    csv_file_name = "#{temp_dir}/#{Time.now.to_i}_#{USERS_FILE_NAME}"
    col_map       = { email: 0, name: 1 }
    errors        = {}
    line          = 0

    return { flash_error: 'Invalid file format' } unless USERS_FILE_CONTENT_TYPE.include?(@csv_file.content_type)

    FileUtils.mkdir_p(temp_dir)
    File.open(csv_file_name, 'wb') { |file| file.write(@csv_file.read) }

    arr_of_arrs = CSV.read(csv_file_name)
    return { flash_error: "You can not import more than #{USERS_UPLOAD_LIMIT} rows in one file" } if arr_of_arrs.count > USERS_UPLOAD_LIMIT + 1

    arr_of_arrs.each do |row|
      line += 1
      row[col_map[:email]] = row[col_map[:email]]&.downcase
      next if (line == 1 && row[col_map[:email]] == 'email') || User.exists?(['lower(email) = ?', row[col_map[:email]]])
      user = User.new(
        email:                    row[col_map[:email]],
        name:                     row[col_map[:name]],
        skip_password_validation: true,
        registration_agreement:   true,
        skip_welcome_email: true
      )

      if user.valid?
        user.skip_confirmation!
        user.save(validate: false)
        user.send_reset_password_instructions_register_from_admin
      else
        errors["Line #{line} (#{user.email})"] = user.errors.full_messages
      end
    end
    FileUtils.rm_f(csv_file_name)
    { validation_errors: errors }
  end
end
