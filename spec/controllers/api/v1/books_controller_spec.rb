require 'rails_helper'

describe Api::V1::BooksController, type: :controller do
  describe 'GET #index' do
    let(:user_books) { create_list(:book, 5, user: user) }

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let!(:expected) do
        ActiveModel::Serializer::CollectionSerializer.new(books_expected,
                                                          serializer: IndexBookSerializer).to_json
      end

      context 'when fetching all the books for user' do
        let(:books_expected) { user_books }

        before { get :index }

        it 'responds with the expected books json' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching books with page and page size params' do
        let(:page) { 1 }
        let(:page_size) { 2 }
        let(:books_expected) { user_books.first(2) }

        before { get :index, params: { page: page, page_size: page_size } }

        it 'responds with the expected books' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching books using filters' do
        let(:author) { 'Jose Martinez' }

        let!(:books_custom) { create_list(:book, 2, user: user, author: author) }
        let(:books_expected) { books_custom }

        before { get :index, params: { author: author } }

        it 'responds with expected books' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'when there is not a user logged in' do
      context 'when fetching all the books for user' do
        before { get :index }

        it_behaves_like 'unauthorized'
      end
    end
  end

  describe 'GET #show' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let(:expected) { ShowBookSerializer.new(book, root: false).to_json }

      context 'when fetching a valid book' do
        let(:book) { create(:book, user: user) }

        before { get :show, params: { id: book.id } }

        it 'responds with the book json' do
          expect(response.body).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching a invalid book' do
        before { get :show, params: { id: Faker::Number.number } }

        it 'responds with 404 status' do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when there is not a user logged in' do
      context 'when fetching an book' do
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

      it_behaves_like 'async_request', 'RetrieveBooksWorker' do
        let(:worker_name) { 'RetrieveBooksWorker' }
        let(:parameters) { [user.id, params] }
      end
    end

    context 'when the user is not authenticated' do
      before { get :index_async }

      it 'returns status code unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
