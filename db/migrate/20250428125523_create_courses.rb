class CreateCourses < ActiveRecord::Migration[7.1]
  def change
    create_table :courses do |t|
      t.string :name
      t.string :city
      t.string :state
      t.string :booking_system
      t.boolean :scraper_active
      t.boolean :has_antibot
      t.integer :blocked_count

      t.timestamps
    end
  end
end
