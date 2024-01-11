require 'spec_helper'
require 'rails_helper'

describe SearchController do
  let(:json_file_service) { instance_double(JsonFileService) }

  before do
    allow(JsonFileService).to receive(:new).and_return(json_file_service)
    allow(json_file_service).to receive(:search).and_return(json_data)
  end

  describe 'GET #index' do
    let(:json_data) { [] }
    it 'renders the index template' do
      get :index

      expect(response).to render_template(:index)
    end
  end

  describe 'GET #search' do

    shared_examples 'empty results' do
      let(:json_data) { [] }

      it 'returns an empty array' do
        get :search, params: { query: query }

        expect(response.body).to eq(json_data.to_json)
      end
    end

    context 'when query is empty' do
      let(:query) { '' }

      it_behaves_like 'empty results'
    end

    context 'when query is not searchable' do
      let(:query) { 'Not searchable query' }

      it_behaves_like 'empty results'
    end

    RSpec.shared_examples 'a search by Vala word' do
      let(:json_data) do
        [
          {
            'Name' => 'Vala',
            'Type' => 'Compiled',
            'Designed by' => 'Jürg Billeter, Raffaele Sandrini'
          }
        ]
      end

      it 'returns the results' do
        get :search, params: { query: query }

        response_body = JSON.parse(response.body)
        expect(response_body.count).to eq(1)
        expect(response_body).to eq(json_data)
      end
    end

    context 'when query is searchable' do
      let(:query) { 'Vala' }

      it_should_behave_like 'a search by Vala word'
    end

    context 'when searching word with downcase' do
      let(:query) { 'vala' }

      it_should_behave_like 'a search by Vala word'
    end

    context 'when searching word with uppercase' do
      let(:query) { 'VALA' }

      it_should_behave_like 'a search by Vala word'
    end

    context 'when searching by one not full word' do
      let(:query) { 'Va' }

      it_should_behave_like 'a search by Vala word'
    end

    context 'when searching by two words' do
      let(:query) { 'Vala Compiled' }

      it_should_behave_like 'a search by Vala word'
    end

    context 'when searching by two replased words' do
      let(:query) { 'Compiled Vala' }

      it_should_behave_like 'a search by Vala word'
    end

    context 'when searching with negative word' do
      let(:query) { 'john -array' }
      let(:json_data) do
        [
          {
            'Name' => 'John',
            'Type' => 'Compiled',
            'Designed by' => 'John Backus'
          },
          {
            'Name' => 'John',
            'Type' => 'Compiled',
            'Designed by' => 'John George Kemeny'
          },
          {
            'Name' => 'John',
            'Type' => 'Compiled',
            'Designed by' => 'John McCarthy'
          },
          {
            'Name' => 'John',
            'Type' => 'Compiled',
            'Designed by' => 'John Mauchly'
          }
        ]
      end

      it 'returns the result' do
        get :search, params: { query: query }

        response_body = JSON.parse(response.body)
        expect(response_body.count).to eq(4)
        expect(response_body.all? { |item| item['Designed by'].include?('John') }).to be_truthy
        expect(response_body.all? { |item| item['Type'].include?('Array') }).to be_falsey
      end
    end
  end
end