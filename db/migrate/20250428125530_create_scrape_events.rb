class CreateScrapeEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :scrape_events do |t|
      t.references :course, null: false, foreign_key: true
      t.datetime :scrape_start
      t.datetime :scrape_end
      t.integer :tee_time_count
      t.boolean :has_error

      t.timestamps
    end
  end
end
