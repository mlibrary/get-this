class Options
  def self.for(patron:, item:)
    list.filter_map do |option|
      option.constantize.for(item) if option.constantize.match?(patron: patron, item: item)
    end
  end

  def self.list
    ["Option::MediaBooking"]
  end
end
