class CreateExtracts < ActiveRecord::Migration
  def change
    create_table :extracts do |t|
      t.string :generated_id
      t.text :name
      t.string :blacklab_pid

      t.timestamps null: false
    end
  end
end
