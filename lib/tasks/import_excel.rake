require 'roo'

namespace :import do
  desc 'Import data from Excel files'
  task excel: :environment do
    # Clear existing data
    puts "Clearing existing data..."
    ScrapeError.delete_all
    TeeTime.delete_all
    ScrapeEvent.delete_all
    Course.delete_all

    def safe_to_i(value)
      value.nil? ? 0 : value.to_s.to_i
    end

    def safe_to_bool(value)
      return false if value.nil?
      value.to_s.downcase == 'true'
    end

    # Import Courses
    puts "Importing courses..."
    courses = {}
    xlsx = Roo::Excelx.new(Rails.root.join('sample_data/courses.xlsx').to_s)
    xlsx.each_row_streaming(offset: 1) do |row|
      next if row[0].nil? # Skip empty rows
      course = Course.create!(
        name: row[1]&.value.to_s,
        city: row[2]&.value.to_s,
        state: row[3]&.value.to_s,
        booking_system: row[4]&.value.to_s,
        scraper_active: safe_to_bool(row[5]&.value),
        has_antibot: safe_to_bool(row[6]&.value),
        blocked_count: safe_to_i(row[7]&.value)
      )
      courses[safe_to_i(row[0]&.value)] = course
    end
    puts "Imported #{courses.size} courses"

    # Import Scrape Events
    puts "Importing scrape events..."
    scrape_events = {}
    xlsx = Roo::Excelx.new(Rails.root.join('sample_data/scrape_events.xlsx').to_s)
    xlsx.each_row_streaming(offset: 1) do |row|
      next if row[0].nil? # Skip empty rows
      course_id = safe_to_i(row[1]&.value)
      course = courses[course_id]
      
      if course.nil?
        puts "Warning: Skipping scrape event for missing course ID: #{course_id}"
        next
      end

      scrape_event = ScrapeEvent.create!(
        course: course,
        scrape_start: row[2]&.value,
        scrape_end: row[3]&.value,
        tee_time_count: safe_to_i(row[4]&.value),
        has_error: safe_to_bool(row[5]&.value)
      )
      scrape_events[safe_to_i(row[0]&.value)] = scrape_event
    end
    puts "Imported #{scrape_events.size} scrape events"

    # Import Tee Times
    puts "Importing tee times..."
    count = 0
    xlsx = Roo::Excelx.new(Rails.root.join('sample_data/tee_times.xlsx').to_s)
    xlsx.each_row_streaming(offset: 1) do |row|
      next if row[0].nil? # Skip empty rows
      course_id = safe_to_i(row[1]&.value)
      scrape_event_id = safe_to_i(row[2]&.value)
      
      course = courses[course_id]
      scrape_event = scrape_events[scrape_event_id]
      
      if course.nil?
        puts "Warning: Skipping tee time for missing course ID: #{course_id}"
        next
      end
      
      if scrape_event.nil?
        puts "Warning: Skipping tee time for missing scrape event ID: #{scrape_event_id}"
        next
      end

      TeeTime.create!(
        course: course,
        scrape_event: scrape_event,
        date: row[3]&.value,
        time: row[4]&.value,
        min_price_cents: safe_to_i(row[5]&.value),
        max_price_cents: safe_to_i(row[6]&.value),
        is_hot_deal: safe_to_bool(row[7]&.value)
      )
      count += 1
    end
    puts "Imported #{count} tee times"

    # Import Scrape Errors
    puts "Importing scrape errors..."
    count = 0
    xlsx = Roo::Excelx.new(Rails.root.join('sample_data/scrape_errors.xlsx').to_s)
    xlsx.each_row_streaming(offset: 1) do |row|
      next if row[0].nil? # Skip empty rows
      scrape_event_id = safe_to_i(row[1]&.value)
      scrape_event = scrape_events[scrape_event_id]
      
      if scrape_event.nil?
        puts "Warning: Skipping scrape error for missing scrape event ID: #{scrape_event_id}"
        next
      end

      ScrapeError.create!(
        scrape_event: scrape_event,
        error_type: row[2]&.value.to_s,
        error_message: row[3]&.value.to_s,
        created_at: row[4]&.value
      )
      count += 1
    end
    puts "Imported #{count} scrape errors"

    puts "Import completed successfully!"
  end
end 