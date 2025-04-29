class ScrapeError < ApplicationRecord
  belongs_to :scrape_event
  has_one :course, through: :scrape_event
end 