# Controller for search data from JSON file
class SearchController < ApplicationController
  def index
  end

  def search
    render json: JsonFileService.new(params[:query]).search
  end
end
