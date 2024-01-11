# Controller for search data from JSON file
class SearchController < ApplicationController
  def index
  end

  def search
    search_query = params[:query]
    results = JsonFileService.search(search_query)

    render json: results
  end
end
