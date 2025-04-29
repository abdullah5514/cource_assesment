require "ostruct"

class BookingSystemsController < ApplicationController
  def index
    @problematic_systems = find_problematic_systems
    @latency_by_system = calculate_latency_by_system
    @scrape_volume = calculate_scrape_volume
    @booking_systems = Course.distinct.pluck(:booking_system).compact
  end

  private

  def find_problematic_systems
    results = Course.joins(scrape_events: :scrape_errors)
          .group('courses.booking_system')
          .select(
            'courses.booking_system',
            'COUNT(scrape_errors.id) as error_count',
            'MAX(scrape_errors.created_at) as last_error_at',
            '(SELECT error_type 
              FROM scrape_errors se2 
              INNER JOIN scrape_events se3 ON se3.id = se2.scrape_event_id 
              INNER JOIN courses c2 ON c2.id = se3.course_id 
              WHERE c2.booking_system = courses.booking_system 
              GROUP BY error_type 
              ORDER BY COUNT(*) DESC 
              LIMIT 1) as most_common_error'
          )
          .order('error_count DESC')

    results.map do |result|
      OpenStruct.new(
        booking_system: result.booking_system,
        error_count: result.error_count,
        last_error_at: result.last_error_at ? Time.parse(result.last_error_at) : nil,
        most_common_error: result.most_common_error
      )
    end
  end

  def calculate_latency_by_system
    Course.joins(:scrape_events)
          .group('courses.booking_system')
          .select(
            'courses.booking_system',
            'AVG((julianday(scrape_events.scrape_end) - julianday(scrape_events.scrape_start)) * 86400) as avg_duration',
            'MIN((julianday(scrape_events.scrape_end) - julianday(scrape_events.scrape_start)) * 86400) as min_duration',
            'MAX((julianday(scrape_events.scrape_end) - julianday(scrape_events.scrape_start)) * 86400) as max_duration'
          )
          .order('avg_duration DESC')
  end

  def calculate_scrape_volume
    date_range = params[:date_range] || '30days'
    booking_system = params[:booking_system]

    query = ScrapeEvent.joins(:course)
    
    case date_range
    when '7days'
      query = query.where('scrape_start >= ?', 7.days.ago)
    when '30days'
      query = query.where('scrape_start >= ?', 30.days.ago)
    when 'custom'
      query = query.where(scrape_start: params[:start_date]..params[:end_date])
    end

    query = query.where(courses: { booking_system: booking_system }) if booking_system.present?

    results = query.group("DATE(scrape_start)")
                  .select(
                    "DATE(scrape_start) as date",
                    "COUNT(CASE WHEN has_error = false THEN 1 END) as success_count",
                    "COUNT(*) as total_count"
                  )
                  .order("DATE(scrape_start)")

    # Convert the results to objects with proper date objects
    volumes = results.map do |result|
      OpenStruct.new(
        date: Date.parse(result.date),
        success_count: result.success_count,
        total_count: result.total_count
      )
    end

    # If no results, return an empty array instead of nil
    volumes.presence || []
  end
end
