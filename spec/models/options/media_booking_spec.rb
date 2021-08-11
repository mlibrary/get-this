describe Option::MediaBooking do
  before(:each) do
    @output = JSON.parse(fixture('booking_availability.json'))
    @closed_days = instance_double(ClosedDays)
    #@item = instance_double(Item, mms_id: 'mms_id', holding_id: 'holding_id', pid: 'pid')
  end
  subject do
    #stub_alma_get_request(url: "bibs/mms_id/holdings/holding_id/items/pid/booking-availability", query: {period: 9, period_type: 'months'}, output: @output.to_json)
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
      expect(subject.booked_dates).to []
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
