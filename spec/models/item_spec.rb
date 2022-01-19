describe Item do
  before(:each) do
    @output = JSON.parse(fixture('item.json'))
  end
  subject do
    stub_alma_get_request(url: "items", output:@output.to_json, query: {item_barcode: '39015009714562', expand: "due_date"} )
    described_class.for('39015009714562')
  end
  context "#title" do
    it "returns string" do
      expect(subject.title).to eq("The hurdy-gurdy /")
    end
  end

  context "#library" do
    it "returns library display name" do
      expect(subject.library).to eq("Music")
    end
  end

  context "#call_number" do
    it "returns the call number" do
      expect(subject.call_number).to eq("ML760 .P18")
    end
  end
  context "#barcode" do
    it "returns the barcode" do
      expect(subject.barcode).to eq("39015009714562")
    end
  end
  context "#due_date" do
    it "returns the duedate" do
      @output["item_data"]["due_date"] = "2021-10-01T01:00:00Z"
      expect(subject.due_date).to eq("2021-10-01T01:00:00Z")
    end
    it "returns empty string for nil due date" do
      @output["item_data"].delete("due_date")
      expect(subject.due_date).to eq("")
    end
  end
  context "#mms_id" do
    it "returns the mms_id" do
      expect(subject.mms_id).to eq("990003116350106381")
    end
  end
  context "#holding_id" do
    it "returns the holding_id" do
      expect(subject.holding_id).to eq("22744541740006381")
    end
  end
  context "#pid" do
    it "returns the pid" do
      expect(subject.pid).to eq("23744541730006381")
    end
  end
  context "#catalog_url" do
    it "returns the catalog_url" do
      expect(subject.catalog_url).to eq("https://search.lib.umich.edu/catalog/record/990003116350106381")
    end
  end
  context "#bookable?" do
    it "returns false if item is not in FVL" do
      expect(subject.bookable?).to eq(false)
    end
    it "returns true if item is in FVL and isn't Loan 8 or Loan 9" do
      #@output["item_data"]["policy"]["value"]
      @output["item_data"]["library"]["value"] = 'FVL'
      expect(subject.bookable?).to eq(true)
    end
    it "returns false if FVL and loan 8" do
      @output["item_data"]["policy"]["value"] = '08'
      @output["item_data"]["library"]["value"] = 'FVL'
      expect(subject.bookable?).to eq(false)
    end
    it "returns false if FVL and loan 9" do
      @output["item_data"]["policy"]["value"] = '09'
      @output["item_data"]["library"]["value"] = 'FVL'
      expect(subject.bookable?).to eq(false)
    end
  end

end
