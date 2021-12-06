describe Option::MediaBooking do
  before(:each) do
    @booking_data = JSON.parse(fixture('booking_availability.json'))
    @closed_days = instance_double(ClosedDays)
    @today = Time.zone.parse("2021-10-01")
    @item = JSON.parse(fixture('item.json'))
  end
  subject do
    described_class.new(booking_data: @booking_data, item: @item, closed_days: @closed_days, today: @today)
  end
  context "#booked_dates"  do
    it "returns an array of dates that includes head time of 2 days and head checkout time of 7 days" do
      allow(@closed_days).to receive(:closed?).and_return(false)
      new_booking_days=(17..23).map{|x| "2021-10-#{x}"}
      head_days = ["2021-10-24","2021-10-25"]
      booking_days = ["2021-10-26","2021-10-27", "2021-10-28","2021-10-29","2021-10-30","2021-10-31", "2021-11-01", "2021-11-02"]
      tail_days = ["2021-11-03", "2021-11-04"]
      expect(subject.booked_dates).to eq([new_booking_days, head_days, booking_days, tail_days].flatten)
    end
    it "handles closed days in head time of booked items" do
      allow(@closed_days).to receive(:closed?).and_return(false)
      allow(@closed_days).to receive(:closed?).with(Date.parse("2021-10-25")).and_return(true)
      allow(@closed_days).to receive(:closed?).with(Date.parse("2021-10-24")).and_return(true)
      october_unavailable_days=(15..31).map{|x| "2021-10-#{x}"}
      november_unavailable_days=(1..4).map{|x| "2021-11-0#{x}"}

      expect(subject.booked_dates).to eq([october_unavailable_days, november_unavailable_days].flatten)
    end
    it "handles closed days in main time of booked items" do
      october_unavailable_days=(17..31).map{|x| "2021-10-#{x}"}
      november_unavailable_days=(1..5).map{|x| "2021-11-0#{x}"}
      allow(@closed_days).to receive(:closed?).and_return(false)
      allow(@closed_days).to receive(:closed?).with(Date.parse("2021-10-31")).and_return(true)
      expect(subject.booked_dates).to eq([october_unavailable_days, november_unavailable_days].flatten)
    end
    it "returns empty array for not booked item" do
      @booking_data["booking_availability"] = nil
      expect(subject.booked_dates).to eq([])
    end
  end

  context "#unavailable_dates" do
    
    it "returns booked_dates plus dates when the institution is closed" do
      initial_unavailable_dates = ["2021-10-01", "2021-10-02"]
      october_unavailable_days=(17..31).map{|x| "2021-10-#{x}"}
      november_unavailable_days=(1..4).map{|x| "2021-11-0#{x}"}
      allow(@closed_days).to receive(:closed?).and_return(false)
      allow(@closed_days).to receive(:closed_days_between).and_return([Date.parse("2021-12-31")])
      expect(subject.unavailable_dates).to eq([initial_unavailable_dates, october_unavailable_days, november_unavailable_days, "2021-12-31"].flatten)

    end

    it "for available item, return only number of processing days from today as unavailable" do
      @booking_data = JSON.parse(fixture('empty_booking_availability.json'))
      allow(@closed_days).to receive(:closed_days_between).and_return([])
      expect(subject.unavailable_dates).to eq(["2021-10-01", "2021-10-02"])
    end
    it "for checked out item returns due date plus processing date as unavailable" do
      @booking_data = JSON.parse(fixture('empty_booking_availability.json'))
      allow(@closed_days).to receive(:closed_days_between).and_return([])
      @item["item_data"]["due_date"] = "2021-10-02T04:59:00Z"
      
      expect(subject.unavailable_dates).to eq(["2021-10-01", "2021-10-02", "2021-10-03", "2021-10-04"])
    end
  end
  context "pickup_locations" do
    it "returns a map of pickup locations" do
      location = subject.pickup_locations.first
      expect(location.code).not_to be_nil
      expect(location.display).not_to be_nil
    end
  end
end
describe Option::MediaBooking, ".book" do
  it "books a valid item" do
    barcode = '39015009714562'
    booking_request_body = {
      request_type: 'BOOKING',
      pickup_location_type: 'LIBRARY',
      pickup_location_library: 'SHAP',
      booking_start_date: "2021-10-24T15:00:00-04:00",
      booking_end_date: "2021-10-26T15:00:00-04:00",
    }.to_json
    item_req = stub_alma_get_request(url: "items", output: fixture('item.json'), query: {item_barcode: barcode} )
    booking_req = stub_alma_post_request(url: "users/tutor/requests", input: booking_request_body, query: {item_pid: '23744541730006381'})
    described_class.book(uniqname: 'tutor', barcode: barcode, booking_date: '2021-10-24', pickup_location: 'SHAP')
    expect(item_req).to have_been_requested 
    expect(booking_req).to have_been_requested 
  end
end
