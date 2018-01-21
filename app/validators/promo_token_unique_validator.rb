class PromoTokenUniqueValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && Promocode.where.not(id: record.id).where(is_promo_token: true).exists?
      record.errors[attribute] << (options[:message] || 'Promo token is already exists')
    end
  end
end
