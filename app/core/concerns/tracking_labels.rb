module TrackingLabels
  extend ActiveSupport::Concern

  def cpa_labels_match?(user_labels, postback_labels)
    return if user_labels.blank? || postback_labels.blank?

    user_labels.symbolize_keys!
    postback_labels.symbolize_keys!

    postback_labels.each do |cpa_key, cpa_value|
      return false if !user_labels.key?(cpa_key) || (cpa_value.present? && user_labels[cpa_key].to_s != cpa_value.to_s)
    end

    true
  end
end
