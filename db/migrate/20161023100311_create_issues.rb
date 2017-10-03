class CreateIssues < ActiveRecord::Migration[5.0]
  def change
    create_table :issues do |t|
      t.string :title
      t.text :text
      t.integer :meter_reader_id

      t.timestamps
    end
  end
end
