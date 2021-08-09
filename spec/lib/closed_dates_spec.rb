describe ClosedDays do
  before(:each) do
    @data = JSON.parse(fixture('hours_exceptions.json'))
  end
  let(:closed) {Date.parse("2021-12-31")}
  subject do
    described_class.new(@data.to_json)
  end
  context "#all_days" do
    it "returns array of all closed days" do
      expect(subject.all_days).to eq([closed])
    end
  end
  context "#closed?(date)" do
    it "returns true if it's a closed date" do
      expect(subject.closed?(closed)).to eq(true)
    end
    it "returns false if it's open" do
      expect(subject.closed?(Date.parse("2021-05-05"))).to eq(false)
    end
  end
  context "closed_days_between(start_date:today,end_date:)" do
    let(:start) { Date.parse('2021-12-01') } 
    it "returns array of closed days between start and end days" do
      expect(subject.closed_days_between(start_date:  start, end_date: closed)).to eq([closed])
    end
    it "returns empty array if there are no closed days" do
      expect(subject.closed_days_between(start_date:  start, end_date: closed - 1.day)).to eq([])
    end
  end
  

end
