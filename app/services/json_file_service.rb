class JsonFileService
  JSON_FILE_PATH = Rails.root.join('public','search_data.json')

  def self.load_data
    @json_data ||= load_json
  end

  def self.search(query)
    data = load_data
    return [] unless data.is_a?(Array)

    result = data.select do |item|
      match_item?(item, query)
    end

    result
  end

  private

  def self.match_item?(item, query)
    query_parts = query.downcase.split

    item_values = item.values.map(&:downcase)
    query_parts.all? do |part|
      #logic for negative search
      if !part.start_with?('-')
        item_values.any? { |value| value.include?(part) }
      else
        item_values.any? { |value| value.include?(part[1..-1]) } ? false : true
      end
    end
  end


  def self.load_json
    JSON.parse(File.read(JSON_FILE_PATH))
  rescue StandardError => e
    Rails.logger.error("Error loading JSON file: #{e.message}")
    {}
  end
end
