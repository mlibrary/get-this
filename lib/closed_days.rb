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
        start_date = Date.parse(entity["from_date"])
        end_date = Date.parse(entity["to_date"])
        number_of_days = (end_date - start_date).to_i
        if number_of_days == 0
          start_date
        else
          (0 .. number_of_days - 1).map{|n| start_date.next_day(n) }
        end
      end
    end &.flatten&.sort 
  end
  def closed_days_between(start_date: Date.today, end_date:)
    all_days.filter_map do |date|
      date.to_s if date > start_date && date < end_date 
    end
  end
end
