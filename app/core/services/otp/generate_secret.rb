class Services::OTP::GenerateSecret
  attr_reader :secret, :uri, :label, :qr_code

  def initialize(user, issuer, need_generate_qr: true)
    @user             = user
    @issuer           = issuer
    @need_generate_qr = need_generate_qr
  end

  def call
    enabling_otp
    prepare_issuer
    generate_uri
    generate_qr if @need_generate_qr
    format_secret

    self
  end

  private

  def enabling_otp
    @user.create_otp_secret!
  end

  def prepare_issuer
    @issuer = @issuer.include?('http') ? URI.parse(@issuer).host : @issuer
  end

  def generate_uri
    @label  = "#{@issuer}:#{@user.email}"
    @uri    = @user.otp_provisioning_uri(@label, issuer: @issuer)
  end

  def generate_qr
    @qr_code = RQRCode::QRCode.new(@uri, size: 12, :level => :h).as_html.html_safe
  end

  def format_secret
    @secret = @user.otp_secret.gsub(/(.{4})(?=.)/, '\1 \2')
  end

  def pack_purpose
    purpose           = { secret: @secret, uri: @uri, label: @label }
    purpose[:qr_code] = @qr_code if @need_generate_qr

    purpose
  end
end
