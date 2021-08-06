class Item
  def initialize(data:)
    @data = data
  end
  def self.for(barcode, options={})
    client = options[:alma_client] || AlmaRestClient.client
    alma_response = client.get("/items", query: {item_barcode: barcode})
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
  def bookable?
    @data.dig("item_data", "library", "value") == 'FVL'
  end
  def call_number
    @data.dig("holding_data", "call_number")
  end
  def barcode
    @data.dig("item_data", "barcode")
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

  class EmptyItem
    ['title'].each do |name|
      define_method(name) do
        ''
      end
    end
  end
end
