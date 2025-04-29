class Course < ApplicationRecord
  has_many :tee_times
  has_many :scrape_events
  has_many :scrape_errors, through: :scrape_events
end 