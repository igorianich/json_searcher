# Service for loading and searching data from the json file
class JsonFileService
  JSON_FILE_PATH = Rails.root.join('public', 'search_data.json') # sets the path to the json file



  def initialize(query = '', json_file_path = JSON_FILE_PATH)
    @json_data = JSON.parse(File.read(json_file_path)) # reads the json file
    @query_parts = query.downcase.split # splits the query into parts
  rescue StandardError => e
    Rails.logger.error("Error loading JSON file: #{e.message}")
    @json_data = {}
  end

  def search
    return [] unless json_data.is_a?(Array) # returns an empty array if the data is not an array

    result = json_data.select do |item| # selects the items that match the query
      query_match_item?(item)
    end

    result.sort_by { |item| get_relevance_score(item) }.reverse # sorts the results by relevance_score
  end

  private

  attr_reader :json_data, :query_parts

  # checks if the item matches the query
  def query_match_item?(item)
    item_values = item.values.map(&:downcase) # gets the values of the item and downcases them
    query_parts.all? do |part|
      # logic for negative search
      if !part.start_with?('-') # if the part does not start with a dash
        item_values.any? { |value| value.include?(part) } # checks if the item values include the part
      else # if the part starts with a dash
        item_values.any? { |value| value.include?(part[1..]) } ? false : true # checks if the item values include the part without the dash
      end
    end
  end

  # calculates the relevance_score of the item to the query
  def get_relevance_score(item)
    item_values = item.values.map(&:downcase) # gets the values of the item and downcases them
    item_values.map! { |value| value.split(',') }.flatten! # splits the item values into parts
    item_values.map!(&:strip) # strips the item values of whitespace

    relevance_score = 0 # initializes the relevance score

    query_parts.each do |part|
      if !part.start_with?('-') && item_values.any? { |value| value == part } # if the part does not start with a dash and the item values include the part
        relevance_score += 1 # adds 1 to the relevance score
      end
    end

    relevance_score # returns the relevance score
  end
end
