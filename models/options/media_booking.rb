class Option
  class MediaBooking < Option
    def self.match?(patron:, item:)
      patron.can_book? && item.bookable?
    end
    def self.book(uniqname:, barcode:, booking_date:, pickup_location:, client: AlmaRestClient.client, item: Item.for(barcode)) 
     
      #3:00 pm because if a library is open at all it is open at 3
      start_date = Time.zone.parse("#{booking_date} 3:00pm")
      #TBD error out if EmptyItem
      client.post("/users/#{uniqname}/requests", query: {item_pid: item.pid}, body: {
        request_type: 'BOOKING',
        pickup_location_type: 'LIBRARY',
        pickup_location_library: pickup_location,
        booking_start_date: start_date.to_s(:iso8601),
        booking_end_date: (start_date + 2.days).to_s(:iso8601) ,
      }.to_json)
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
    def type
      'book-this'
    end
    def title
      'Pick up media at the library'
    end
    def subtitle
      'Expected availability 1-3 days'
    end
    def booked_dates
      @data["booking_availability"]&.map do |booking|
        head_time_counter = 0 
        start_date = (Time.zone.parse(booking["from_time"])).to_date
        end_date = Time.zone.parse(booking["to_time"]).to_date + num_days_tail_time.days

        while head_time_counter < num_days_head_time + num_days_of_checkout
          start_date = start_date - 1.day
          head_time_counter = head_time_counter + 1 unless @closed_days.closed?(start_date)
        end

        dates =  []
        while start_date <= end_date
          dates.push(start_date.to_s(:db)) 
          start_date = start_date + 1.day
        end
        dates
      end&.flatten&.sort || []
    end
    def pickup_locations
      [ 
        {code: 'SHAP', display: 'Shapiro Undergraduate Library'},
        {code: 'AAEL', display: 'Art Architecture & Engineering'},
        {code: 'BUHR', display: 'Buhr Shelving Facility'},
        {code: 'MUSIC', display: 'Music'},
        {code: 'TAUB', display: 'Taubman Health Sciences'},
        {code: 'FLINT', display: 'UM-Flint'},
        {code: 'DRBN', display: 'Mardigan Library'},
      ].map{|x| OpenStruct.new(code: x[:code], display: x[:display]) }
    end
    def unavailable_dates
      closed = @closed_days.closed_days_between(end_date: Time.zone.today + 9.months).map do |x|
        x.to_s(:db)
      end
      [booked_dates, closed].flatten.uniq.sort
    end
    def unavailable_dates_formatted
      unavailable_dates.map{|x| "\"#{x}\""}.join(", ")
    end
    private
    def num_days_of_checkout
      2
    end
    def num_days_head_time
      3
    end
    def num_days_tail_time
      3
    end
  end
end