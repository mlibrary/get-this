require 'json'
require 'byebug'
require 'date'
class ClosedDays
  def initialize(data = File.read('./config/institution_hours_exceptions.json'))
    @data = ::JSON.parse(data)
  end
  def all_days
    @data["open_hour"].filter_map do |entity|
      if entity.dig("status", "value") == "CLOSE"
        start_date = Time.zone.parse(entity["from_date"]).to_date
        end_date = Time.zone.parse(entity["to_date"]).to_date
        dates = []
        while start_date <= end_date
          dates.push(start_date) 
          start_date = start_date + 1.day
        end
        dates
      end
    end &.flatten&.sort 
  end
  def closed_days_between(start_date: Date.today, end_date:)
    all_days.filter_map do |date|
      date if date >= start_date && date <= end_date 
    end
  end
  def closed?(date)
    all_days.any?{|x| x == date }
  end
end
