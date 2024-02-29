module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def index
        return render_long_page_size if page_size.to_i > max_page_size
        return render_invalid_type if type.present? && !Note.types.keys.include?(type)
        render json: notes, status: :ok, each_serializer: BriefNoteSerializer
      end

      def show
        render json: note, status: :ok, serializer: NoteSerializer
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
        Note.filtered filter_params, order, page, page_size
      end

      def filter_params
        params.permit(%i[type]).merge user_id: current_user.id
      end

      def note
        Note.find params.require(:id)
      end

      def type
        params[:type]
      end

      def order
        params[:order].presence || :desc
      end

      def page
        params[:page].presence || 1
      end

      def page_size
        params[:page_size].presence || max_page_size
      end

      def max_page_size
        100
      end

      def render_long_page_size
        render json: { error: large_page_size_error_message }, status: :bad_request
      end

      def large_page_size_error_message
        I18n.t('responses.note.long_page_size', max_page_size: max_page_size)
      end

      def render_invalid_type
        render json: { error: invalid_type_error_message }, status: :unprocessable_entity
      end

      def invalid_type_error_message
        I18n.t('responses.note.invalid_type')
      end

      def create_note
        current_user.notes.create! create_note_params
        render_created
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue StandardError
        render_create_errors(note)
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
    end
  end
end
