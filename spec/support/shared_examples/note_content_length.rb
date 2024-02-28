shared_examples 'note_content_length' do |word_count_limit, expected_content_lengths|
  context "when content has #{word_count_limit} words" do
    let(:content) { 'word ' * word_count_limit }

    it "returns #{expected_content_lengths[0]}" do
      expect(subject.content_length).to eq(expected_content_lengths[0])
    end
  end

  context "when content has less than #{word_count_limit} words" do
    let(:content) { 'word ' * (word_count_limit - 1) }

    it "returns #{expected_content_lengths[0]}" do
      expect(subject.content_length).to eq(expected_content_lengths[0])
    end
  end

  context "when content has more than #{word_count_limit} words" do
    let(:content) { 'word ' * (word_count_limit + 1) }

    it "returns #{expected_content_lengths[1]}" do
      expect(subject.content_length).to eq(expected_content_lengths[1])
    end
  end
end
