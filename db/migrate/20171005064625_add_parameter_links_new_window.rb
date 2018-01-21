class AddParameterLinksNewWindow < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(name: 'links.new_window', value: 1, description: 'Open header menu links in a new window (1 - yes, 0 - no)')
  end
end
