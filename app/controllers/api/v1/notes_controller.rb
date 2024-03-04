module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def index
        return render_long_page_size if invalid_page_size?
        return render_invalid_type if invalid_type?
        render json: notes, status: :ok, each_serializer: BriefNoteSerializer
      end

      def show
        render json: note, status: :ok, serializer: NoteSerializer
      end

      private

      def notes
        current_user.notes.with_type(type, order).page(page).per(page_size)
      end

      def note
        Note.find(params.require(:id))
      end

      def type
        params[:type]
      end

      def invalid_type?
        type.present? && invalid_note_type
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

      def invalid_page_size?
        page_size.to_i > max_page_size
      end

      def max_page_size
        100
      end

      def render_long_page_size
        render json: { error: large_page_size_error_message }, status: :bad_request
      end

      def large_page_size_error_message
        "page_size is too long, max allowed is #{max_page_size}"
      end

      def render_invalid_type
        render json: { error: "invalid type #{type}" }, status: :unprocessable_entity
      end

      def invalid_note_type
        !Note.types.keys.include? type
      end
    end
  end
end
