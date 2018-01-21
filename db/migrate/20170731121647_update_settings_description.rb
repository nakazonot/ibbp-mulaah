class UpdateSettingsDescription < ActiveRecord::Migration[5.1]
  def change
    Parameter.find_by(name: 'ico.date_start').update(description: 'Дата начала ICO (yyyy-mm-dd hh:mm:ss)')
    Parameter.find_by(name: 'presale.date_start').update(description: 'Дата начала присейла (yyyy-mm-dd hh:mm:ss)')
    Parameter.find_by(name: 'ico.date_end').update(description: 'Дата окончания ICO (yyyy-mm-dd hh:mm:ss)')
    Parameter.find_by(name: 'presale.date_end').update(description: 'Дата окончания присейла (yyyy-mm-dd hh:mm:ss)')
  end
end
