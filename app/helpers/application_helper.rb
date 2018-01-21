module ApplicationHelper
  include Concerns::Currency

  def ibbp_layout_meta_tags(parameters)
    meta_tags = {}
    meta_tags['title']                    = parameters['site.meta.title']       if parameters['site.meta.title'].present?
    meta_tags['charset']                  = 'utf-8'
    meta_tags['description']              = parameters['site.meta.description'] if parameters['site.meta.description'].present?
    meta_tags['keywords']                 = parameters['site.meta.keywords']    if parameters['site.meta.keywords'].present?
    meta_tags['viewport']                 = "width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"
    meta_tags['turbolinks-cache-control'] = "no-cache"
    display_meta_tags meta_tags
  end

  def ibbp_meta_tags
    params = Parameter.get_all
    return if params['referral.social_share_buttons'].blank?
    image_type = {
      '.jpg'  => 'image/jpeg',
      '.jpeg' => 'image/jpeg',
      '.png'  => 'image/png'
    }
    content_for(:ibbp_meta_tags) do
      show_tags                      = { og: { url: request.original_url } }
      show_tags[:og]['type']         = 'website'
      show_tags[:og]['title']        = params['site.og.title']        if params['site.og.title'].present?
      show_tags[:og]['image']        = params['site.og.image']        if params['site.og.image'].present?
      show_tags[:og]['image:type']   = params['site.og.image.type']   if params['site.og.image.type'].present?
      show_tags[:og]['image:width']  = params['site.og.image.width']  if params['site.og.image.width'].present?
      show_tags[:og]['image:height'] = params['site.og.image.height'] if params['site.og.image.height'].present?
      show_tags[:og]['description']  = params['site.og.description']  if params['site.og.description'].present?

      display_meta_tags show_tags
    end
  end

  def active_class(link_path)
    current_page?(link_path) ? 'active' : ''
  end

  def time_frontend(d)
    d.blank? ? '' : d.strftime('%H:%M %Z')
  end

  def date_frontend_long(d)
    d.blank? ? "" : d.strftime('%d %B %Y')
  end

  def date_payment_history(d)
    d.blank? ? "" : d.strftime("%Y-%m-%d %H:%M")
  end

  def date_time_with_timezone(d)
    d.blank? ? "" : d.strftime("%d %b %Y %H:%M %Z")
  end

  def diff_in_days(d1, d2)
    return '' if d1.blank? || d2.blank?
    (d1.to_date - d2.to_date).to_i
  end

  def date_format(d)
    return '' if d.blank?
    date.strftime("%F %T")
  end

  def date_counter_format(d)
    return '' if d.blank?
    d.iso8601
  end

  def show_user(user, parameters)
    return protected_value(user[:email]) if parameters['user.show_identification'] == Parameter::USER_SHOW_IDENTIFICATION_EMAIL
    return user[:id] if parameters['user.show_identification'] == Parameter::USER_SHOW_IDENTIFICATION_ID
    ""
  end

  def referral_status(referral)
    if referral[:bounty_amount].to_f > 0
      status = 'Tokenholder'
    elsif referral[:confirmed_at].present?
      status = 'Confirmed'
    else
      status = 'Registration incomplete'
    end

    status
  end

  def referral_balance_status(referral)
    if referral[:bounty_amount] > 0
      status = 'Active Referral'
    elsif referral[:confirmed_at].present?
      status = 'Confirmed'
    else
      status = 'Registration incomplete'
    end

    status
  end

  def eth_wallet_display(wallet)
    return '' if wallet.nil?
    return wallet if wallet.length <= 8
    "#{wallet.first(4)}...#{wallet.last(4)}"
  end

  def referral_link(user)
    return root_url(ref: user.referral_uuid) if ENV['REFERRAL_HOST_WITH_SCHEMA'].blank?
    "#{ENV['REFERRAL_HOST_WITH_SCHEMA']}/?ref=#{user.referral_uuid}"
  end

  def agreement_date_header(date)
    date.strftime('%B %d, %Y')
  end

  def agreement_date_body(date)
    date.strftime('%B %d, %Y (%I:%M %p %Z)')
  end

  def self.format_counter(used, total)
    counter  = "#{used}"
    counter += " / #{total}" if total.present?

    counter
  end

  def self.admin_pending_transaction(payment)
    return '' unless payment.status == Payment::PAYMENT_STATUS_PENDING
    '<span class="glyphicon glyphicon-time text-danger" data-toggle="tooltip" data-placement="top" title="Pending"></span>'
  end

  def self.format_translation_variables(variables)
    variables.map { |variable| "%{#{variable}}" }.join(', ')
  end

  def has_asset?(path)
    if Rails.configuration.assets.compile
      Rails.application.precompiled_assets.include?(path)
    else
      Rails.application.assets_manifest.assets[path].present?
    end
  end

  def currency_icon(currency_code, css_class)
    path = "currency-icons/#{currency_code}.svg"
    path = 'currency-icons/default.svg' unless has_asset?(path)

    image_tag(path, class: css_class)
  end

  def range_picker_dates(dates_raw)
    starting_at = nil
    ending_at   = nil

    if dates_raw.present?
      dates = dates_raw.split(' - ')
      starting_at = Date.parse(dates.first)
      ending_at   = Date.parse(dates.second)
    end

    { starting_at: starting_at, ending_at: ending_at }
  end

  def add_quoutes(str)
    arr = str.split(',')
    arr.map { |v| "'#{v.strip}'" }.join(',').html_safe
  end

  def protected_value(value)
    result = value
    len = result.split('@').first.length
    if len < 5
      result[len/2..len-1] = '*' * (len - len / 2)
    else
      result[len/2-1..len/2+1] = '***'
    end
    result
  end

  def payment_types_collection(payment_types)
    filter = {}
    filter[Payment::PAYMENT_TYPE_BALANCE]          = 'Deposit' if (payment_types & [Payment::PAYMENT_TYPE_BALANCE]).present?
    filter[Payment::PAYMENT_TYPE_PURCHASE]         = 'Purchase' if (payment_types & [Payment::PAYMENT_TYPE_BALANCE]).present?
    filter[Payment::PAYMENT_TYPE_BUY_TOKEN_BONUS]  = 'Bonus' if (payment_types & [Payment::PAYMENT_TYPE_BUY_TOKEN_BONUS]).present?
    filter[Payment::PAYMENT_TYPE_REFUND]           = 'Refund' if (payment_types & [Payment::PAYMENT_TYPE_REFUND]).present?
    filter[Payment::PAYMENT_TYPE_REFUND_TOKENS]    = 'Refund Tokens' if (payment_types & [Payment::PAYMENT_TYPE_REFUND_TOKENS]).present?
    filter[Payment::PAYMENT_TYPE_TRANSFER_TOKENS]  = 'Transfer Tokens' if (payment_types & [Payment::PAYMENT_TYPE_TRANSFER_TOKENS]).present?
    filter['referral']                             = 'Referral' if (payment_types & [Payment::PAYMENT_TYPE_REFERRAL_BOUNTY, Payment::PAYMENT_TYPE_REFERRAL_USER, Payment::PAYMENT_TYPE_REFERRAL_BONUS_BALANCE, Payment::PAYMENT_TYPE_REFERRAL_BOUNTY_BALANCE]).present?
    filter['promocode']                            = 'Promo code Bonus' if (payment_types & [Payment::PAYMENT_TYPE_PROMOCODE_BONUS, Payment::PAYMENT_TYPE_PROMOCODE_BOUNTY]).present?
    filter[Payment::PAYMENT_TYPE_LOYALTY_BONUS]    = 'Loyalty Bonus' if (payment_types & [Payment::PAYMENT_TYPE_LOYALTY_BONUS]).present?
    filter.collect { |index, status| [status, index] }
  end

  def add_param_to_uri(uri, param_name, param_value)
    uri       = URI(uri)
    params    = URI.decode_www_form(uri.query || '') << [param_name, param_value]
    uri.query = URI.encode_www_form(params)

    uri.to_s
  end

  def platform_link
    Parameter.get_all['system.platform_link'].present? ? Parameter.get_all['system.platform_link'] : root_url
  end

  def get_purchase_agreements
    result = []
    data = Translation.find_by(key: 'purchase.agreement_html')
    return result if data.value.blank?
    Nokogiri::HTML(data.value).search('div').each do |value|
      result << value.children.to_s.strip.html_safe if value.children.to_s.present?
    end
    result
  end
end
