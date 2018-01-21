class Services::Users::ImportKycCsv

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
  USERS_FILE_NAME         = "users_kyc.csv"
  USERS_UPLOAD_LIMIT      = 1000

  def initialize(csv_file)
    @csv_file = csv_file
  end

  def call
    temp_dir      = Rails.root.join('tmp', USERS_FILE_PATH)
    csv_file_name = "#{temp_dir}/#{Time.now.to_i}_#{USERS_FILE_NAME}"
    col_map       = { email: 0, kyc_date: 1, kyc_result: 2 }
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
      next if line == 1 && row[col_map[:email]] == 'email'
      user = User.where('lower(email) = ?', row[col_map[:email]]).first
      next if user.blank?
      user.kyc_date = row[col_map[:kyc_date]]
      user.kyc_result = row[col_map[:kyc_result]].to_b
      errors["Line #{line} (#{user.email})"] = user.errors.full_messages unless user.save
    end
    FileUtils.rm_f(csv_file_name)
    { validation_errors: errors }
  end
end