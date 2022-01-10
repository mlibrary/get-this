class Item
  def initialize(data:)
    @data = data
  end
  def self.for(barcode, options={})
    client = options[:alma_client] || AlmaRestClient.client
    alma_response = client.get("/items", query: {item_barcode: barcode, expand: "due_date"})
    if alma_response.code == 200
      Item.new(data: alma_response.parsed_response)
    else
      EmptyItem.new
    end
  end

  def title
    @data.dig("bib_data","title")
  end
  def library
    @data.dig("item_data", "library", "desc")
  end
  def library_code
    @data.dig("item_data", "library", "value")
  end
  def item_policy
    @data.dig("item_data", "policy", "value")
  end
  def bookable?
     library_code == 'FVL' && ['08','09'].exclude?(item_policy)
  end
  def call_number
    @data.dig("holding_data", "call_number")
  end
  def barcode
    @data.dig("item_data", "barcode")
  end
  def due_date
    @data.dig("item_data","due_date") || ""
  end
  def mms_id
    @data.dig("bib_data","mms_id")
  end
  def holding_id
    @data.dig("holding_data","holding_id")
  end
  def pid
    @data.dig("item_data","pid")
  end

  def catalog_url
    "https://search.lib.umich.edu/catalog/record/#{mms_id}"
  end

  class EmptyItem < self
    def initialize
      @data = {}
    end
    #['title', 'catalog_url', "library", "call_number", "pid",].each do |name|
      #define_method(name) do
        #''
      #end
    #end
    def bookable?
      false
    end
  end
end
