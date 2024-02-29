require 'rails_helper'

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

RSpec.describe Note, type: :model do
  subject(:note) { create(:note, utility: utility, content: content, type: type) }

  let(:utility) { north_utility }
  let(:type) { described_class.types.values.sample }
  let(:content) { Faker::Lorem.paragraphs(number: 3).join("\n") }
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
    let(:content) { 'it has four words' }

    it 'returns the correct number of words' do
      expect(subject.word_count).to equal 4
    end
  end

  describe '#content_length' do
    let(:type) { :critique }

    context 'with NorthUtility' do
      let(:utility) { north_utility }

      include_examples 'note_content_length', 50, %w[short medium]

      include_examples 'note_content_length', 100, %w[medium long]
    end

    context 'with SouthUtility' do
      let(:utility) { south_utility }

      include_examples 'note_content_length', 60, %w[short medium]

      include_examples 'note_content_length', 120, %w[medium long]
    end
  end

  describe '#save!' do
    context 'with NorthUtility' do
      let(:utility) { north_utility }
      let(:short_content_length) { 50 }
      let(:medium_content_length) { 100 }

      context 'when the note is a review' do
        let(:type) { :review }

        context 'when count is less than 50' do
          let(:content) { 'word ' * (short_content_length - 1) }

          it 'succeeds' do
            expect { subject.save! }.not_to raise_error
          end
        end

        context 'when word count is 50' do
          let(:content) { 'word ' * short_content_length }

          it 'succeeds' do
            expect { subject.save! }.not_to raise_error
          end
        end

        context 'when word count is greater than 50' do
          let(:content) { 'word ' * (short_content_length + 1) }

          it 'fails' do
            expect { subject.save! }.to raise_error ActiveRecord::RecordInvalid
          end
        end
      end

      context 'when the note is a critique' do
        let(:type) { :critique }

        context 'when word count is less than 50' do
          let(:content) { 'word ' * (short_content_length - 1) }

          it 'succeeds' do
            expect { subject.save! }.not_to raise_error
          end
        end

        context 'when word count is 50' do
          let(:content) { 'word ' * short_content_length }

          it 'succeeds' do
            expect { subject.save! }.not_to raise_error
          end
        end

        context 'when word count is greater than 50' do
          let(:content) { 'word ' * (short_content_length + 1) }

          it 'succeeds' do
            expect { subject.save! }.not_to raise_error
          end
        end
      end
    end

    context 'with SouthUtility' do
      let(:utility) { south_utility }
      let(:short_content_length) { 60 }
      let(:medium_content_length) { 120 }

      context 'when the note is a review' do
        let(:type) { :review }

        context 'when count is less than 60' do
          let(:content) { 'word ' * (short_content_length - 1) }

          it 'succeeds' do
            expect { subject.save! }.not_to raise_error
          end
        end

        context 'when word count is 60' do
          let(:content) { 'word ' * short_content_length }

          it 'succeeds' do
            expect { subject.save! }.not_to raise_error
          end
        end

        context 'when word count is greater than 60' do
          let(:content) { 'word ' * (short_content_length + 1) }

          it 'fails' do
            expect { subject.save! }.to raise_error ActiveRecord::RecordInvalid
          end
        end
      end

      context 'when the note is a critique' do
        let(:type) { :critique }

        context 'when word count is less than 60' do
          let(:content) { 'word ' * (short_content_length - 1) }

          it 'succeeds' do
            expect { subject.save! }.not_to raise_error
          end
        end

        context 'when word count is 60' do
          let(:content) { 'word ' * short_content_length }

          it 'succeeds' do
            expect { subject.save! }.not_to raise_error
          end
        end

        context 'when word count is greater than 60' do
          let(:content) { 'word ' * (short_content_length + 1) }

          it 'succeeds' do
            expect { subject.save! }.not_to raise_error
          end
        end
      end
    end
  end
end
