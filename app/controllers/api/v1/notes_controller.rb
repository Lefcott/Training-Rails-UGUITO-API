module Api
  module V1
    class NotesController < ApplicationController
      def index
        return render_long_page_size if page_size.to_i > max_page_size
        return render_invalid_type if type.present? && !Note.types.keys.include?(type)
        render json: notes, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok, serializer: ShowNoteSerializer
      end

      private

      def notes
        order, page, page_size = params.values_at(:order, :page, :page_size)
        Note.all.where(index_params).order(created_at: order || :desc).page(page).per(page_size)
      end

      def index_params
        params.permit %i[type]
      end

      def show_note
        Note.find(params.require(:id))
      end

      def type
        params[:type]
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
        "page_size is too long, max allowed is #{max_page_size}"
      end

      def render_invalid_type
        render json: { error: "invalid type #{type}" }, status: :unprocessable_entity
      end
    end
  end
end
