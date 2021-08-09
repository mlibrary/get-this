class Patron
  def initialize(data:)
    @data = data
  end
  def self.for(uniqname, options={})
    client = options[:alma_client] || AlmaRestClient.client
   
    alma_response = client.get("/users/#{uniqname}")
    if alma_response.code == 200
      Patron.new(data: alma_response.parsed_response)
    else
      NotInAlma.new
    end
  end
  def user_group
    @data.dig('user_group','value')
  end
  def statistic_categories
    @data.dig("user_statistic")&.map do |stat|
      stat.dig("statistic_category", "value")
    end
  end

  def can_book?
    faculty? || staff? || gsi? || faculty_proxy?
  end
  
  class NotInAlma < self
    def initialize
    end
    def user_group
      ''
    end
    def statistic_categories
      []
    end
  end

  private
  def has_category(category)
    statistic_categories.any?{|stat| stat == category}
  end
  def staff?
    user_group == "02"
  end
  def faculty?
    user_group == "01"
  end
  def gsi?
    has_category('GE')
  end
  def faculty_proxy?
    has_category('PR')
  end
end

