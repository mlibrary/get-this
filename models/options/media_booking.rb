class Option
  class MediaBooking
    def self.match(patron:, item:)
      patron.can_book? && item.bookable?
    end
    def self.for(item, options={})
      client = options[:alma_client] || AlmaRestClient.client
      alma_response = client.get("/bibs/#{item.mms_id}/holdings/#{item.holding_id}/items/#{item.pid}/booking-availability", query: {period: 9, period_type: 'months'})
      if alma_response.code == 200
        self.new(data: alma_response.parsed_response)
      else
      end
    end
    def initialize(data:, closed_days: ClosedDays.new)
      @data = data
      @closed_days = closed_days
    end
    def booked_dates
      @data["booking_availability"]&.map do |booking|
        head_time_counter = 0 
        start_date = (Time.zone.parse(booking["from_time"])).to_date
        end_date = Time.zone.parse(booking["to_time"]).to_date

        while head_time_counter < num_days_head_time
          start_date = start_date - 1.day
          head_time_counter = head_time_counter + 1 unless @closed_days.closed?(start_date)
        end

        dates =  []
        while start_date <= end_date
          dates.push(start_date.to_s(:db)) 
          start_date = start_date + 1.day
        end
        dates
      end&.flatten&.sort
    end
    def unavailable_dates
      closed = @closed_days.closed_days_between(end_date: Time.zone.today + 9.months).map do |x|
        x.to_s(:db)
      end
      [booked_dates, closed].flatten.uniq.sort
    end
    private
    def num_days_head_time
      2
    end
  end
end
