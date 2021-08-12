describe Option::MediaBooking do
  before(:each) do
    @output = JSON.parse(fixture('booking_availability.json'))
    @closed_days = instance_double(ClosedDays)
  end
  subject do
    described_class.new(data: @output, closed_days: @closed_days)
  end
  context "#booked_dates"  do
    it "returns an array of dates that includes head time of two days" do
      allow(@closed_days).to receive(:closed?).and_return(false)
      expect(subject.booked_dates).to eq(["2021-10-24","2021-10-25","2021-10-26","2021-10-27", "2021-10-28"])
    end
    it "handles closed days in head time of booked items" do
      allow(@closed_days).to receive(:closed?).and_return(false)
      allow(@closed_days).to receive(:closed?).with(Date.parse("2021-10-25")).and_return(true)
      allow(@closed_days).to receive(:closed?).with(Date.parse("2021-10-24")).and_return(true)
      expect(subject.booked_dates).to eq(["2021-10-22","2021-10-23", "2021-10-24","2021-10-25","2021-10-26","2021-10-27", "2021-10-28"])
    end
    it "returns empty array for not booked item" do
      @output["booking_availability"] = nil
      expect(subject.booked_dates).to eq([])
    end

  end

  context "#unavailable_dates" do
    it "returns booked_dates plus dates when the institution is closed" do
      allow(@closed_days).to receive(:closed?).and_return(false)
      allow(@closed_days).to receive(:closed_days_between).and_return([Date.parse("2021-12-31")])
      expect(subject.unavailable_dates).to eq(["2021-10-24","2021-10-25","2021-10-26","2021-10-27", "2021-10-28", "2021-12-31"])

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
