require 'i18n/backend/active_record'

class I18n::Backend::ActiveRecord::Translation
  scope :filter_by_value,    -> (q)         { where("value ILIKE ?", "%#{q}%") }

  def self.ransackable_scopes(_auth_object = nil)
    [:filter_by_value]
  end

  def reset_i18n_cache!
    # Rails.cache.delete_matched("i18n/*")
    I18n.backend.reload!
  end
end


Translation = I18n::Backend::ActiveRecord::Translation
if Translation.table_exists?
  I18n.backend = I18n::Backend::ActiveRecord.new

  # I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Memoize)
  # I18n::Backend::Simple.send(:include, I18n::Backend::Memoize)

  # I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Cache)
  # I18n::Backend::Simple.send(:include, I18n::Backend::Cache)
  # I18n.cache_store = ActiveSupport::Cache.lookup_store(:memory_store)

  I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)
  I18n.backend = I18n::Backend::Chain.new(I18n.backend, I18n::Backend::Simple.new)
end
