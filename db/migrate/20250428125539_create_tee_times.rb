class CreateTeeTimes < ActiveRecord::Migration[7.1]
  def change
    create_table :tee_times do |t|
      t.references :course, null: false, foreign_key: true
      t.references :scrape_event, null: false, foreign_key: true
      t.datetime :date
      t.datetime :time
      t.integer :min_price_cents
      t.integer :max_price_cents
      t.boolean :is_hot_deal

      t.timestamps
    end
  end
end
