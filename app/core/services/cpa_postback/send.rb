class Services::CpaPostback::Send
  include Concerns::Log::Logger

  ERROR_NOT_ENOUGH_PARAMETERS      = 'error_not_enough_parameters'.freeze
  ERROR_POSTBACKS_NOT_FOUND        = 'error_postbacks_not_found'.freeze
  ERROR_LABELS_NOT_MATCHED         = 'error_labels_not_matched'.freeze
  ERROR_USER_NOT_FOUND             = 'error_user_not_found'.freeze

  attr_reader :error

  def initialize(postback_action, user_id, params = {})
    @postback_action = postback_action
    @postbacks_uri   = []
    @user_id         = user_id
    @params          = params
  end

  def call
    find_user
    find_postback
    prepare_postbacks_uri
    send_postbacks

    @postbacks_uri
  rescue Services::CpaPostback::SendError => e
    @error = e.message
    log_error("cpa_postback: #{@postback_action}. User #{@user_id} #{e.message}")
    nil
  end

  private

  def find_user
    @user = User.find_by(id: @user_id)

    raise Services::CpaPostback::SendError, ERROR_USER_NOT_FOUND if @user.nil?
  end

  def find_postback
    @postbacks = ::CpaPostback.where(action: @postback_action)

    raise Services::CpaPostback::SendError, ERROR_POSTBACKS_NOT_FOUND if @postbacks.empty?
  end

  def additional_params(postback_id)
    {
      user_id:     @user.id,
      user_email:  @user.email,
      send_at:     Time.now.in_time_zone.iso8601,
      postback_id: postback_id
    }
  end

  def prepare_postbacks_uri
    @postbacks.each do |postback|
      next if postback.labels.present? && !cpa_labels_match?(@user.tracking_labels, postback.labels)

      interpolated_uri = postback_uri_interpolation(postback)
      @postbacks_uri << interpolated_uri if interpolated_uri.present?
    end
  end

  def postback_uri_interpolation(postback)
    postback_uri  = postback.postback_uri
    postback_keys = postback_uri.scan(/\{([a-z|0-9|_|-]+)\}/)
    postback_keys = postback_keys.map { |uri_label| uri_label.first.to_sym }
    user_params   = @user.tracking_labels.nil? ? {} : @user.tracking_labels
    user_params   = user_params.merge(@params).merge(additional_params(postback.id))

    if (postback_keys - user_params.keys).empty?
      postback_keys.each { |url_label| postback_uri.gsub!("{#{url_label}}", user_params[url_label].to_s) }
      postback_uri
    else
      log_error("cpa_postback: #{@postback_action}. #{ERROR_NOT_ENOUGH_PARAMETERS}, "\
                "user_params: #{user_params}, postback_keys: #{postback_keys}")
      nil
    end
  end

  def send_postbacks
    @postbacks_uri.each do |postback_uri|
      begin
        response = HTTParty.get(postback_uri)
        log_info("CPA Postback. Action: #{@postback_action}, URI: #{postback_uri}, User ##{@user.id}, "\
             "Response Code: #{response.code}")
      rescue => error
        log_error("cpa_postback: #{@postback_action} #{postback_uri}, "\
                  "user #{@user.id}, params: #{@params}, #{error.message}")
      end
    end
  end

  def cpa_labels_match?(user_labels, postback_labels)
    return false if user_labels.blank? || postback_labels.blank?

    user_labels.symbolize_keys!
    postback_labels.symbolize_keys!

    postback_labels.each do |cpa_key, cpa_value|
      if !user_labels.key?(cpa_key) || (cpa_value.present? && user_labels[cpa_key].to_s != cpa_value.to_s)
        log_error("cpa_postback: #{@postback_action}. #{ERROR_LABELS_NOT_MATCHED},
                 user_labels: #{@user.tracking_labels}, postback_labels: #{postback_labels}")
        return false
      end
    end

    true
  end
end
