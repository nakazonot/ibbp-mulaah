class ApplicationController < ActionController::Base
  protect_from_forgery

  # before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :get_config_parameters
  before_action :set_referrer, unless: :user_signed_in?
  before_action :create_body_id
  before_action :parse_tracking_labels_from_query

  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      if request.xhr?
        render json: {error: p(exception.message)}, status: 403 
      else
        redirect_to root_path, :alert => p(exception.message)
      end
    else
      authenticate_user!
    end
  end

  protected

  def create_body_id
    if params[:controller].present? && params[:action].present?
      @body_id = "#{params[:controller].gsub('/', '-')}-#{params[:action]}"
    end
  end

  def ajax_error(errors)
    render json: (errors.is_a?(String) ? {common: errors} : errors), status: :unprocessable_entity
  end

  def ajax_ok(data = {})
    render json: data
  end

  def get_config_parameters
    @config_parameters = Parameter.get_all
  end

  def after_sign_in_path_for(resource)
    if resource.sign_in_count == 1
      parse_tracking_labels_from_query
      resource.cpa_postback_sign_up
    end

    cookies.delete(:referral, domain: get_top_domain)
    return admin_root_path if can?(:administrate, :all)
    root_path
  end

  def access_denied(exception)
    redirect_to root_path, alert: exception.message
  end

  def authenticate_user!
    if user_signed_in?
      super
    elsif request.xhr?
      head 403
    else
      redirect_to new_user_session_path
    end
  end

  def set_referrer
    return if params[:ref].blank?
    cookies[:referral] = { value: params[:ref], expires: 180.days.from_now, domain: get_top_domain }

    redirect_to url_for(params.permit!.except(:ref))
  end

  def check_ico
    return redirect_to close_ico_path unless can?(:ico_enabled, :ico)
  end

  def redirect_to_root
    redirect_to root_path
  end

  def get_top_domain
    ".#{URI.parse(root_url).host.split('.').last(2).join('.')}"
  end

  def update_ga_client_id(user)
    return if cookies['_ga'].blank?

    user.update_attribute(:ga_client_id, cookies["_ga"].split('.')[2..3].join('.'))
  end

  def parse_tracking_labels_from_query
    tracking_labels_whitelist = Parameter.allowed_tracking_labels
    tracking_labels           = request.query_parameters.select { |key| tracking_labels_whitelist.include?(key) }
    if cookies[:tracking_labels].present?
      tracking_labels         = JSON.parse(cookies[:tracking_labels]).merge(tracking_labels)
    end

    tracking_labels  = Hash[tracking_labels.sort_by { |key, _value| key }]
    if tracking_labels.present? && cookies[:tracking_labels] != tracking_labels.to_json
      cookies[:tracking_labels] = { value: tracking_labels.to_json, expires: 180.days.from_now }
    end

    if cookies[:tracking_labels].present? && user_signed_in?
      current_user.update_tracking_labels(JSON.parse(cookies[:tracking_labels]))
      cookies.delete(:tracking_labels)
    end
  end
end
