require 'rails_helper'

RSpec.describe Note, type: :model do
  subject(:note) { create(:note) }

  %i[title content type].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  it { is_expected.to belong_to :user }

  it { is_expected.to have_one(:utility).through(:user) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'word_count' do
    it 'returns the correct number of words' do
      subject.content = 'it has four words'
      expect(subject.word_count).to equal 4
    end
  end

  describe 'content_length' do
    before do
      subject.utility.short_content_length = 50
      subject.utility.medium_content_length = 100
    end

    it 'returns short for content with less than 50 words' do
      subject.content = 'word ' * 49
      expect(subject.content_length).to eq 'short'
    end

    it 'returns short for content with 50 words' do
      subject.content = 'word ' * 50
      expect(subject.content_length).to eq 'short'
    end

    it 'returns medium for content with less than 100 words' do
      subject.content = 'word ' * 99
      expect(subject.content_length).to eq 'medium'
    end

    it 'returns medium for content with 100 words' do
      subject.content = 'word ' * 100
      expect(subject.content_length).to eq 'medium'
    end

    it 'returns long for content with more than 100 words' do
      subject.content = 'word ' * 101
      expect(subject.content_length).to eq 'long'
    end
  end

  describe 'valid_word_count' do
    before do
      subject.utility.short_content_length = 50
    end

    describe 'for note with type: review' do
      before do
        subject.type = :review
      end

      it 'succeeds for short word count less than 50' do
        subject.content = 'word ' * 49
        subject.valid_word_count
        expect(subject.errors[:content]).to be_empty
      end

      it 'succeeds for a word count of 50' do
        subject.content = 'word ' * 50
        subject.valid_word_count
        expect(subject.errors[:content]).to be_empty
      end

      it 'fails for a word count greater than 50' do
        subject.content = 'word ' * 51
        subject.valid_word_count
        expect(subject.errors[:content]).to include(I18n.t('note.word_count_validation', max_words: 50))
      end
    end

    describe 'for note with type: critique' do
      before do
        subject.type = :critique
      end

      it 'succeeds for a word count less than 50' do
        subject.content = 'word ' * 49
        subject.valid_word_count
        expect(subject.errors[:content]).to be_empty
      end

      it 'succeeds for a word count of 50' do
        subject.content = 'word ' * 50
        subject.valid_word_count
        expect(subject.errors[:content]).to be_empty
      end

      it 'succeeds for a word count greater than 50' do
        subject.content = 'word ' * 51
        subject.valid_word_count
        expect(subject.errors[:content]).to be_empty
      end
    end
  end
end
