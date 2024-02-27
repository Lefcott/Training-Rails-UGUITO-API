require 'rails_helper'

RSpec.describe Note, type: :model do
  subject(:note) { create(:note, utility: north_utility) }

  let(:north_utility) { create(:north_utility, code: 1) }
  let(:south_utility) { create(:south_utility, code: 1) }

  %i[title content type].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  it { is_expected.to have_one(:utility).through(:user) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe '#word_count' do
    it 'returns the correct number of words' do
      subject.content = 'it has four words'
      expect(subject.word_count).to equal 4
    end
  end

  describe '#content_length' do
    context 'with NorthUtility' do
      subject(:note) { create(:note, type: :critique, utility: north_utility, content: content) }

      context 'when content has less than 50 words' do
        let(:content) { 'word ' * 49 }

        it 'returns short' do
          expect(subject.content_length).to eq 'short'
        end
      end

      context 'when content has 50 words' do
        let(:content) { 'word ' * 50 }

        it 'returns short' do
          expect(subject.content_length).to eq 'short'
        end
      end

      context 'when content has less than 100 words' do
        let(:content) { 'word ' * 99 }

        it 'returns medium' do
          expect(subject.content_length).to eq 'medium'
        end
      end

      context 'when content has 100 words' do
        let(:content) { 'word ' * 100 }

        it 'returns medium' do
          expect(subject.content_length).to eq 'medium'
        end
      end

      context 'when content has more than 100 words' do
        let(:content) { 'word ' * 101 }

        it 'returns long' do
          expect(subject.content_length).to eq 'long'
        end
      end
    end

    context 'with SouthUtility' do
      subject(:note) { create(:note, type: :critique, utility: south_utility, content: content) }

      context 'when content has less than 60 words' do
        let(:content) { 'word ' * 59 }

        it 'returns short' do
          expect(subject.content_length).to eq 'short'
        end
      end

      context 'when content has 60 words' do
        let(:content) { 'word ' * 60 }

        it 'returns short' do
          subject.content = 'word ' * 60
          expect(subject.content_length).to eq 'short'
        end
      end

      context 'when content has less than 120 words' do
        let(:content) { 'word ' * 119 }

        it 'returns medium' do
          expect(subject.content_length).to eq 'medium'
        end
      end

      context 'when content has 120 words' do
        let(:content) { 'word ' * 120 }

        it 'returns medium' do
          expect(subject.content_length).to eq 'medium'
        end
      end

      context 'when content has more than 120 words' do
        let(:content) { 'word ' * 121 }

        it 'returns long' do
          expect(subject.content_length).to eq 'long'
        end
      end
    end
  end

  describe '#validate_word_count' do
    subject(:note) { create(:note, utility: north_utility) }

    describe 'for note with type: review' do
      before do
        subject.type = :review
      end

      context 'when count is less than 50' do
        it 'succeeds' do
          subject.content = 'word ' * 49
          subject.validate_word_count
          expect(subject.errors[:content]).to be_empty
        end
      end

      context 'when word count is 50' do
        it 'succeeds' do
          subject.content = 'word ' * 50
          subject.validate_word_count
          expect(subject.errors[:content]).to be_empty
        end
      end

      context 'when word count is greater than 50' do
        it 'fails' do
          subject.content = 'word ' * 51
          subject.validate_word_count
          expect(subject.errors[:content]).to include(I18n.t('note.word_count_validation', max_words: 50))
        end
      end
    end

    describe 'for note with type: critique' do
      before do
        subject.type = :critique
      end

      context 'when word count is less than 50' do
        it 'succeeds' do
          subject.content = 'word ' * 49
          subject.validate_word_count
          expect(subject.errors[:content]).to be_empty
        end
      end

      context 'when word count is 50' do
        it 'succeeds' do
          subject.content = 'word ' * 50
          subject.validate_word_count
          expect(subject.errors[:content]).to be_empty
        end
      end

      context 'when word count is greater than 50' do
        it 'succeeds' do
          subject.content = 'word ' * 51
          subject.validate_word_count
          expect(subject.errors[:content]).to be_empty
        end
      end
    end
  end
end
