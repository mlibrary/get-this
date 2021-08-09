describe Option::MediaBooking do
  before(:each) do
    @output = JSON.parse(fixture('booking_availability.json'))
    @item = instance_double(Item, mms_id: 'mms_id', holding_id: 'holding_id', pid: 'pid')
  end
  subject do
    stub_alma_get_request(url: "bibs/mms_id/holdings/holding_id/items/pid/booking-availability", query: {period: 9, period_type: 'months'}, output: @output.to_json)
    described_class.for(@item)
  end
  context "#booked_dates"  do
    it "returns an array of dates that includes head time of two days" do
      expect(subject.booked_dates).to eq(["2021-10-24","2021-10-25","2021-10-26","2021-10-27", "2021-10-28"])
    end
    it "returns nil for not booked item" do
      @output["booking_availability"] = nil
      expect(subject.booked_dates).to be_nil
    end
  end

end
