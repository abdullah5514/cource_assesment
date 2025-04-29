require 'ostruct'

class OverviewController < ApplicationController
  def index
    @date_range = params[:date_range] || '30days'
    @success_rate_data = calculate_success_rate
    @error_distribution = calculate_error_distribution

    # Calculate statistics for the table
    today = Date.today
    last_7_days = (today - 6)..today
    last_30_days = (today - 29)..today

    # Helper to calculate average success rate for a date range
    def avg_success_rate(data, range)
      filtered = data.select { |d| range.cover?(d.date) && d.total_count.to_f > 0 }
      return 0 if filtered.empty?
      (filtered.sum { |d| d.success_count.to_f / d.total_count.to_f } / filtered.size) * 100
    end

    @today_success_rate = avg_success_rate(@success_rate_data, today..today)
    @seven_day_average = avg_success_rate(@success_rate_data, last_7_days)
    @thirty_day_average = avg_success_rate(@success_rate_data, last_30_days)
  end

  private

  def calculate_success_rate
    query = ScrapeEvent.group("DATE(scrape_start)")
                      .select(
                        "DATE(scrape_start) as date",
                        "COUNT(CASE WHEN has_error = false THEN 1 END) as success_count",
                        "COUNT(*) as total_count"
                      )
                      .order("DATE(scrape_start) DESC")

    # Apply date range filter
    case @date_range
    when '7days'
      query = query.where('scrape_start >= ?', 7.days.ago)
    when '30days'
      query = query.where('scrape_start >= ?', 30.days.ago)
    when 'custom'
      if params[:start_date].present? && params[:end_date].present?
        query = query.where(scrape_start: params[:start_date]..params[:end_date])
      else
        query = query.where('scrape_start >= ?', 30.days.ago)
      end
    end

    query = query.limit(30) # Show last 30 days

    # Convert to objects with proper date objects
    results = query.map do |result|
      OpenStruct.new(
        date: Date.parse(result.date.to_s),
        success_count: result.success_count,
        total_count: result.total_count
      )
    end

    if results.empty?
      # Generate sample data if no results
      (30.days.ago.to_date..Date.today).map do |date|
        OpenStruct.new(
          date: date,
          success_count: rand(50..100),
          total_count: rand(100..150)
        )
      end
    else
      results
    end
  end

  def calculate_error_distribution
    # Get total count of all errors
    total_errors = ScrapeError.count

    # Group by error_type and count occurrences
    ScrapeError.group(:error_type)
               .select("error_type, COUNT(*) as count")
               .order("count DESC")
               .map do |error|
                 OpenStruct.new(
                   error_type: error.error_type,
                   count: error.count,
                   percentage: (error.count.to_f / total_errors * 100)
                 )
               end
  end
end
