require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  let(:user) { create(:user) }
  let(:utility) { user.utility }

  describe 'GET #index' do
    let(:expected_keys) { %w[id title type content_length] }

    before do
      create_list(:note, 5, type: :review, user: user)
      create_list(:note, 3, type: :critique, user: user)
    end

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      context 'when fetching all the notes for user' do
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
        let(:expected_error) { I18n.t('responses.note.long_page_size', max_page_size: 100) }

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

          it 'responds with 422 status' do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'responds with invalid type error' do
            expect(response_body['error']).to eq(I18n.t('responses.note.invalid_type'))
          end
        end
      end
    end

    context 'when there is no user logged in' do
      context 'when fetching all the notes for user' do
        before { get :index }

        it_behaves_like 'unauthorized'
      end
    end
  end

  describe 'GET #show' do
    let(:expected_keys) { %w[id title type word_count created_at content content_length user] }

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

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

    context 'when there is no user logged in' do
      context 'when fetching a specific note for user' do
        before { get :show, params: { id: Faker::Number.number } }

        it_behaves_like 'unauthorized'
      end
    end
  end

  describe 'GET #index_async' do
    context 'when the user is authenticated' do
      include_context 'with authenticated user'

      let(:params) { { author: Faker::Book.author } }

      before { get :index_async, params: params }

      it_behaves_like 'async_request' do
        let(:worker_name) { 'RetrieveNotesWorker' }
        let(:parameters) { [user.id, params] }
      end
    end

    context 'when the user is not authenticated' do
      before { get :index_async }

      it_behaves_like 'unauthorized'
    end
  end

  describe 'POST #create' do
    let(:title) { Faker::Book.title }
    let(:type) { :review }
    let(:content) { Faker::Lorem.paragraphs(number: 3).join("\n") }

    context 'when there is a user logged in' do
      let(:params) { { title: title, type: type, content: content } }

      include_context 'with authenticated user'

      context 'when creating a valid note' do
        before { post :create, params: params }

        it 'responds with 201 status' do
          expect(response).to have_http_status :created
        end

        it 'responds with the expected message' do
          expect(response_body['message']).to eq I18n.t('responses.note.created')
        end

        it 'creates a note' do
          expect { post :create, params: params }.to change(Note, :count).by(1)
        end

        it 'associates the user' do
          expect { post :create, params: params }.to change { user.notes.count }.by(1)
        end
      end

      context 'when a required parameter is missing' do
        let(%i[title type content].sample) { nil }

        before { post :create, params: params }

        it 'responds with 400 status' do
          expect(response).to have_http_status :bad_request
        end

        it 'responds with the expected error' do
          expect(response_body['error']).to eq I18n.t('responses.global.missing_required_params')
        end

        it 'does not create a note' do
          expect { post :create, params: params }.not_to change(Note, :count)
        end
      end

      context 'when sending an invalid type' do
        let(:type) { :invalid_type }

        before { post :create, params: params }

        it 'responds with 400 status' do
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'responds with the expected error' do
          expect(response_body['error']).to eq I18n.t('responses.note.invalid_type')
        end

        it 'does not create a note' do
          expect { post :create, params: params }.not_to change(Note, :count)
        end
      end

      context 'when creating a note with a large content' do
        let(:content) { 'word ' * 100 }

        before { post :create, params: params }

        it 'responds with 422 status' do
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'responds with the expected error' do
          expect(response_body['error']).to include I18n.t('note.word_count_validation', max_words: utility.short_content_length)
        end

        it 'does not create a note' do
          expect { post :create, params: params }.not_to change(Note, :count)
        end
      end
    end

    context 'when there is no user logged in' do
      context 'when creating a note' do
        before { post :create }

        it_behaves_like 'unauthorized'

        it 'does not create a note' do
          expect { post :create }.not_to change(Note, :count)
        end
      end
    end
  end
end
