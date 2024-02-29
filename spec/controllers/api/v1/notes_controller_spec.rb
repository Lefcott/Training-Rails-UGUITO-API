require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let(:user) { create(:user) }
    let(:expected_keys) { %w[id title type content_length] }

    before do
      create_list(:note, 5, type: :review, user: user)
      create_list(:note, 3, type: :critique, user: user)
    end

    context 'when fetching all the notes' do
      before { get :index }

      it 'responds with 200 status' do
        expect(response).to have_http_status(:ok)
      end

      it 'responds with 8 notes' do
        expect(response_body.length).to eq(8)
      end

      it 'responds with the expected keys' do
        expect(response_body.map(&:keys)).to all contain_exactly(*expected_keys)
      end
    end

    context 'when fetching notes with page and page size params' do
      let(:page) { 1 }
      let(:page_size) { 2 }
      let(:notes_expected) { user_notes.sort_by(&:id).reverse.first 2 }

      before { get :index, params: { page: page, page_size: page_size } }

      it 'responds with 200 status' do
        expect(response).to have_http_status(:ok)
      end

      it 'responds with 2 notes' do
        expect(response_body.length).to eq(2)
      end

      it 'responds with the expected keys' do
        expect(response_body.map(&:keys)).to all contain_exactly(*expected_keys)
      end
    end

    context 'when page_size is too long' do
      let(:page) { 1 }
      let(:page_size) { 2000 }
      let(:expected_error) { 'page_size is too long, max allowed is 100' }

      before { get :index, params: { page: page, page_size: page_size } }

      it 'responds with 400 status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'responds with the expected error' do
        expect(response_body['error']).to eq(expected_error)
      end
    end

    describe 'get notes by type' do
      before { get :index, params: { type: type } }

      context 'when fetching notes of type review' do
        let(:type) { 'review' }

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end

        it 'responds with 5 notes' do
          expect(response_body.length).to eq(5)
        end

        it 'responds with the expected keys' do
          expect(response_body.map(&:keys)).to all contain_exactly(*expected_keys)
        end
      end

      context 'when fetching notes of type critique' do
        let(:type) { 'critique' }

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end

        it 'responds with 3 notes' do
          expect(response_body.length).to eq(3)
        end

        it 'responds with the expected keys' do
          expect(response_body.map(&:keys)).to all contain_exactly(*expected_keys)
        end
      end

      context 'when fetching notes of an invalid type' do
        let(:type) { Faker::String.random }

        it 'responds with 400 status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'responds with invalid type error' do
          expect(response_body['error']).to eq("invalid type #{type}")
        end
      end
    end
  end

  describe 'GET #show' do
    let(:expected_keys) { %w[id title type word_count created_at content content_length user] }
    let(:user) { create(:user) }

    context 'when fetching a valid note' do
      let(:note) { create(:note, user: user) }

      before { get :show, params: { id: note.id } }

      it 'responds with 200 status' do
        expect(response).to have_http_status(:ok)
      end

      it 'responds with the expected keys' do
        expect(response_body.keys).to contain_exactly(*expected_keys)
      end
    end

    context 'when fetching an invalid note' do
      before { get :show, params: { id: Faker::Number.number } }

      it 'responds with 404 status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
