class Services::OTP::GenerateProvisioningUri
  def initialize(user, issuer)
    @user     = user
    @issuer   = issuer
    @label    = nil
    @uri      = nil
    @qr_code  = nil
  end

  def call
    generate_uri
    generate_qr
    format_secret

    { uri: @uri, qr_code: @qr_code, secret: @secret, label: @label }
  end

  private

  def generate_uri
    @label  = "#{@issuer}:#{@user.email}"
    @uri    = @user.otp_provisioning_uri(@label, issuer: @issuer)
  end

  def generate_qr
    @qr_code = RQRCode::QRCode.new(@uri, size: 12, :level => :h).as_html().html_safe
  end

  def format_secret
    @secret = @user.otp_secret.gsub(/(.{4})(?=.)/, '\1 \2')
  end
end
