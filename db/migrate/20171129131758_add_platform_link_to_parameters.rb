class AddPlatformLinkToParameters < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(
      name: 'system.platform_link',
      value: '',
      description: 'This link will be used in some payment-notice emails'
    )
  end
end
