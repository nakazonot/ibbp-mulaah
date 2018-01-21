class AddedAllowedTrackingLabelsToParameters < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(
      name: 'system.tracking_labels.whitelist',
      value: 'utm_campaign,utm_term,utm_content,utm_medium,utm_source,utm_network,utm_adposition,utm_keyword,utm_placement,clickid,gclid',
      description: 'Allowed list of tracking labels that can be saved'
    )
  end
end
