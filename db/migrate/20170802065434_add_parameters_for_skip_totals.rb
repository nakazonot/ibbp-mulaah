class AddParametersForSkipTotals < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(
      [
        { name: 'system.skip_totals_block_date_to', description: 'Дата, после которой будут выводиться блок "TOTAL" на главной странице (yyyy-mm-dd hh:mm:ss)'},
        { name: 'links.license_agreement', description: 'Ссылка на лицензионное соглашение'}
      ]
    )
  end
end
