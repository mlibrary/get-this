describe Patron do
  before(:each) do
    @output = JSON.parse(fixture('mrio_user_alma.json'))
  end
  subject do
    stub_alma_get_request(url: "users/tutor", output:@output.to_json )
    Patron.for('tutor')
  end
  context "#user_group" do
    it "returns user_group value" do
      expect(subject.user_group).to eq("02")
    end
  end
  context "#statistic_categories" do
    it "returns array of values" do
      expect(subject.statistic_categories).to eq(["ST"])
    end
  end
  context "#can_book?" do
    it "returns true for staff" do
      expect(subject.can_book?).to eq(true)
    end
    it "returns true for faculty" do
      @output["user_group"]["value"] = "01"
      expect(subject.can_book?).to eq(true)
    end
    it "returns true for gsi" do
      @output["user_group"]["value"] = "03"
      @output["user_statistic"][0]["statistic_category"]["value"] = 'GE'
      expect(subject.can_book?).to eq(true)
    end
    it "returns true for faculty proxy" do
      @output["user_group"]["value"] = "04"
      @output["user_statistic"][0]["statistic_category"]["value"] = 'PR'
      expect(subject.can_book?).to eq(true)
    end
    it "returns false for non gsi / faculty proxy graduate student" do
      @output["user_group"]["value"] = "03"
      expect(subject.can_book?).to eq(false)
    end
  end

end
