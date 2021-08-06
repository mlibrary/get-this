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
        start_date = Date.parse(booking["from_time"])
        end_date = Date.parse(booking["to_time"])
        number_of_days = (end_date - start_date).to_i
        (0 .. number_of_days - 1).map{|n| start_date.next_day(n).to_s }
      end&.flatten&.sort
    end
  end
end
