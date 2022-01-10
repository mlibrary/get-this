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
        self.new(booking_data: alma_response.parsed_response, item: item)
      else
      end
    end
    def initialize(booking_data:, item:, closed_days: ClosedDays.new, today: Time.zone.today)
      @item = item
      @data = booking_data
      @closed_days = closed_days
      @today = today
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
        start_date = Time.zone.parse(booking["from_time"]).to_date
        end_date = start_date

        #calculate end date after booking start time
        process_time_counter = 0
        while process_time_counter < num_days_process_time + num_days_of_checkout
          end_date = end_date + 1.day
          process_time_counter = process_time_counter + 1 unless @closed_days.closed?(end_date)
        end

        #calculate start date before booking start time
        process_time_counter = 0 
        while process_time_counter < num_days_process_time + num_days_of_checkout
          start_date = start_date - 1.day
          process_time_counter = process_time_counter + 1 unless @closed_days.closed?(start_date)
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
      YAML.load_file('./config/pickup_location_labels.yml').to_a.map do |code, display| 
          OpenStruct.new(code: code, display: display)
      end
    end
    def unavailable_dates
      closed = @closed_days.closed_days_between(end_date: @today + 9.months).map do |x|
        x.to_s(:db)
      end
      [initial_unavailable_dates, booked_dates, closed].flatten.uniq.sort
    end
    def unavailable_dates_formatted
      unavailable_dates.map{|x| "\"#{x}\""}.join(", ")
    end
    def unavailable_dates_text
      dates = unavailable_dates.map{|x| Date.parse(x)}
      by_month = dates.chunk{|x| x.month}
      ranges = by_month.map do |m, day|
        day.chunk_while do |a, b| 
          b.mday == a.mday + 1
        end
      end.flatten(1)

      ranges.map do |big_r|
        big_r.map do |r|
          if r.size == 1
            r.first.strftime("%b %-d, %Y")
          else
            r.first.strftime("%b %-d") + " - " + r.last.strftime("%-d, %Y")
          end
        end
      end.flatten(1).join(", ")
    end
    def initial_unavailable_dates
      due_date = @item.dig("item_data","due_date")
      if due_date.empty?
        days = num_days_process_time - 1
      else
        days = (Time.zone.parse(due_date).to_date - @today.to_date).to_i + num_days_process_time
      end
      (0..days).map{|x| (@today + x.day).to_date.to_s}
    end
    private
    def num_days_of_checkout
      7
    end
    def num_days_process_time
      2
    end
  end
end
