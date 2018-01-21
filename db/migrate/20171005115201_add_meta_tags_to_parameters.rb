class AddMetaTagsToParameters < ActiveRecord::Migration[5.1]
  def change
    Parameter.create([
      { name: 'site.meta.title', value: 'Bookbuilding Platform', description: 'Meta tag. ICO site title' },
      { name: 'site.meta.keywords', description: 'Meta tag. Comma separated list of keywords' },
      { name: 'site.meta.favicon', description: 'URL to the image that will be used as the ICO site favicon' }
    ])

    Parameter.find_by_name('site.description').update_columns(name: 'site.meta.description', description: 'Meta tag. ICO site description')
  end
end
