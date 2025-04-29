class CreateScrapeErrors < ActiveRecord::Migration[7.1]
  def change
    create_table :scrape_errors do |t|
      t.references :scrape_event, null: false, foreign_key: true
      t.string :error_type
      t.text :error_message

      t.timestamps
    end
  end
end
