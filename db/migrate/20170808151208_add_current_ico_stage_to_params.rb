class AddCurrentIcoStageToParams < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(name: 'system.current_ico_stage', value: 'Before Early Bird at Presale', description: 'Текущий этап ICO')
  end
end
