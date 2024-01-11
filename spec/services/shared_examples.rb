RSpec.shared_examples 'a search by Microsoft word' do
  it 'returns the results' do
    expect(subject.count).to eq(8)
    expect(subject.all? { |item| item['Designed by'].include?('Microsoft') }).to be_truthy
  end
end

RSpec.shared_examples 'a search by two words' do
  it 'returns the result' do
    expect(subject.count).to eq(1)
    expect(subject.all? { |item| item['Name'].include?('Common Lisp') }).to be_truthy
  end
end