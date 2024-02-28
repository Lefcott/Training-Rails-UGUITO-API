module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def index
        max_page_size = 100

        if params[:page_size].to_i > max_page_size
          error_message = I18n.t('responses.note.long_page_size', max_page_size: max_page_size)
          return render json: { error: error_message }, status: :bad_request
        end

        if params[:type] && invalid_note_type
          error_message = I18n.t('responses.note.invalid_type')
          return render json: { error: error_message }, status: :unprocessable_entity
        end
        render json: notes_filtered, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok, serializer: ShowNoteSerializer
      end

      def create
        required_params = { error: I18n.t('responses.global.missing_required_params') }
        invalid_note_type_err = { error: I18n.t('responses.note.invalid_type') }

        return render json: required_params, status: :bad_request if invalid_create_params

        if invalid_note_type
          return render json: invalid_note_type_err, status: :unprocessable_entity
        end

        create_note
      end

      private

      def render_created
        render json: { message: I18n.t('responses.note.created') }, status: :created
      end

      def render_create_errors(note)
        render json: { errors: note.errors.full_messages }, status: :unprocessable_entity
      end

      def notes
        current_user.notes
      end

      def notes_filtered
        order, page, page_size = params.values_at(:order, :page, :page_size)
        notes.where(filtering_params).order(created_at: order || :desc).page(page).per(page_size)
      end

      def filtering_params
        params.permit %i[type]
      end

      def show_note
        notes.find(params.require(:id))
      end

      def create_note_params
        params.permit(:title, :type, :content)
      end

      def invalid_create_params
        params[:title].blank? || params[:content].blank? || params[:type].blank?
      end

      def invalid_note_type
        !Note.types.keys.include? params[:type]
      end

      def create_note
        current_user.notes.create! create_note_params
        render_created
      rescue Exceptions::InvalidContentLengthError => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue StandardError
        render_create_errors(note)
      end
    end
  end
end
