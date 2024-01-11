require 'spec_helper'
require 'rails_helper'
require_relative 'shared_examples'

JSON_FILE_PATH = 'public/search_data.json'.freeze

describe JsonFileService do

  describe '.load_data' do
    it 'returns the json data if it exists, otherwise it loads it' do
      expected = JSON.parse(File.read(JSON_FILE_PATH))
      actual = described_class.load_data
      expect(actual).to eq(expected)
    end
  end

  describe '.search' do
    subject { described_class.search(query) }

    context 'when the data is not an array' do
      let(:query) { 'Not searchable query' }
      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    context 'when searching by one match word' do
      let(:query) { 'Microsoft' }
      it_should_behave_like 'a search by Microsoft word'
    end

    context 'when searching word with downcase' do
      let(:query) { 'microsoft' }
      it_should_behave_like 'a search by Microsoft word'
    end

    context 'when searching word with uppercase' do
      let(:query) { 'MICROSOFT' }
      it_should_behave_like 'a search by Microsoft word'
    end

    context 'when searching by one not full word' do
      let(:query) { 'Microso' }
      it_should_behave_like 'a search by Microsoft word'
    end

    context 'when searching by two words' do
      let(:query) { 'Common Lisp' }
      it_should_behave_like 'a search by two words'
    end

    context 'when searching by two replased words' do
      let(:query) { 'Lisp Common' }
      it_should_behave_like 'a search by two words'
    end

    context 'when searching with negative word' do
      let(:query) { 'john -array' }

      it 'returns the result' do
        expect(subject.count).to eq(4)
        expect(subject.all? { |item| item['Designed by'].include?('John') }).to be_truthy
        expect(subject.all? { |item| item['Type'].include?('Array') }).to be_falsey
      end
    end

    context 'when searching with match word for one of fields' do
      let(:query) { 'd' }

      it 'returns the result' do
        expect(subject.first['Name']).to eq('D')
      end
    end
  end

  describe '.match_item?' do
    subject { described_class.match_item?(item, query) }
    let(:item) { { 'Name' => 'D', 'Type' => 'Array', 'Designed by' => 'John Backus' } }

    context 'when the item matches the query' do
      let(:query) { 'John' }

      it 'returns true' do
        expect(subject).to be_truthy
      end
    end

    context 'when the item does not match the query' do
      let(:query) { 'Johnson' }

      it 'returns false' do
        expect(subject).to be_falsey
      end
    end

    context 'when the item matches the query with negative word' do
      let(:query) { 'John -Array' }

      it 'returns false' do
        expect(subject).to be_falsey
      end
    end

    context 'when the item matches the query by few words' do
      let(:query) { 'John Array' }

      it 'returns true' do
        expect(subject).to be_truthy
      end
    end

    context 'when the item matches the query by few words with negative word' do
      let(:query) { 'John Array -D' }

      it 'returns false' do
        expect(subject).to be_falsey
      end
    end
  end

  describe '.relevance' do
    subject { described_class.relevance(item, query) }
    let(:item) { { 'Name' => 'D', 'Type' => 'Array', 'Designed by' => 'John Backus' } }

    context 'when the query matches one item key value' do
      let(:query) { 'Array' }

      it 'returns 1' do
        expect(subject).to eq(1)
      end
    end

    context 'when the query matches two item key values' do
      let(:query) { 'Array D' }

      it 'returns 2' do
        expect(subject).to eq(2)
      end
    end

    context 'when the query matches one item key value and one negative word' do
      let(:query) { 'Array -D' }

      it 'returns 1' do
        expect(subject).to eq(1)
      end
    end
  end
end
