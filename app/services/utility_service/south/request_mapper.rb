module UtilityService
  module South
    class RequestMapper < UtilityService::RequestMapper
      def retrieve_books(params)
        author_params(params)
      end

      def retrieve_notes(params)
        author_params(params)
      end

      private

      def author_params(params)
        { Autor: params['author'] }
      end
    end
  end
end
