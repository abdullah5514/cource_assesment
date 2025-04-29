class ScrapeEvent < ApplicationRecord
  belongs_to :course
  has_many :tee_times
  has_many :scrape_errors
end 