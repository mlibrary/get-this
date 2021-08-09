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
    def initialize(data:)
      @data = data
    end
    def booked_dates
      @data["booking_availability"]&.map do |booking|
        start_date = (Time.zone.parse(booking["from_time"]) - 2.days).to_date
        end_date = Time.zone.parse(booking["to_time"]).to_date
        dates =  []
        while start_date <= end_date
          dates.push(start_date.to_s(:db)) 
          start_date = start_date + 1.day
        end
        dates
      end&.flatten&.sort
    end
  end
end
