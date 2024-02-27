require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let(:user) { create(:user) }
    let(:user_notes) { create_list(:note, 5, user: user) }

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let!(:expected) do
        ActiveModel::Serializer::CollectionSerializer.new(notes_expected,
                                                          serializer: IndexNoteSerializer).to_json
      end

      context 'when fetching all the notes for user' do
        let(:notes_expected) { user_notes.sort_by(&:id).reverse }

        before { get :index }

        it 'responds with the expected notes json' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes with page and page size params' do
        let(:page) { 1 }
        let(:page_size) { 2 }
        let(:notes_expected) { user_notes.sort_by(&:id).reverse.first 2 }

        before { get :index, params: { page: page, page_size: page_size } }

        it 'responds with the expected notes' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when page_size is too long' do
        let(:page) { 1 }
        let(:page_size) { 2000 }
        let(:notes_expected) { user_notes.sort_by(&:id).reverse }
        let(:expected_error) { 'page_size is too long, max allowed is 100' }

        before { get :index, params: { page: page, page_size: page_size } }

        it 'responds with 400 status' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'responds with the expected error' do
          expect(response_body['error']).to eq(expected_error)
        end
      end

      context 'when fetching notes using filters' do
        let(:type) { 'review' }
        let!(:notes_custom) { create_list(:note, 2, type: type, content: 'words', user: user) }
        let(:notes_expected) { notes_custom.sort_by(&:id).reverse }

        before { get :index, params: { type: type } }

        it 'responds with expected notes' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe 'GET #show' do
    let(:expected) { ShowNoteSerializer.new(note, root: false).to_json }
    let(:user) { create(:user) }


    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      context 'when fetching a valid note' do
        let(:note) { create(:note, user: user) }

        before { get :show, params: { id: note.id } }

        it 'responds with the note json' do
          expect(response.body).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
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
end
